# frozen_string_literal: true
require_relative "test_helper"
require "zen_wallet/hd/account"
require "mixins/address"
# require "zen_wallet/store"
# require "zen_wallet/insight"
module ZenWallet
  module HD
    class AccountsTest < HDTest
      include AddressMixin

      def setup
        super
        @address_repo = mock
        @store = mock
        @store.responds_like_instance_of(Store)
        @container.register("store", @store)
        @container.register("address_repo", @address_repo)
        @model = @acc_balance_model
        @account = Account.new(@container, @model)
        @finders = [@model.wallet_id, @model.index]
        @registry = mock
        @registry.responds_like_instance_of(Account::Registry)
        @account.instance_variable_set("@registry", @registry)
        @transactions = mock
        @transactions.responds_like_instance_of(Store::Transactions)
        @store.stubs(:transactions).returns(@transactions)
        @utxo = mock
        @utxo.responds_like_instance_of(Store::Utxo)
        @store.stubs(:utxo).returns(@utxo)
        # @address_repo.stubs(:find_or_create).with()
      end

      def test_request_receive_address
        @registry.stubs(:fill_gap_limit)
        address_obj = address_model(@model, 0, 0)
        @registry.stubs(:free_address).with(0).returns(address_obj.address)
        @registry.stubs(:ensure_requested_mark).with(address_obj.address)
        assert_equal address_obj.address, @account.request_receive_address
      end

      def test_receive_address
        address_obj = address_model(@model, 0, 0)
        # Return last free
        @registry.stubs(:free_address).with(0).returns(address_obj.address)
        assert_equal address_obj.address, @account.receive_address
        # If not requests new one
        @registry.stubs(:free_address).with(0).returns(nil)
        @account.stubs(:request_receive_address).returns(address_obj.address)
        assert_equal address_obj.address, @account.receive_address
      end

      def test_change_address
        address_obj = address_model(@model, 1, 0)
        @registry.expects(:free_address).with(1).returns(address_obj.address)
        assert_equal address_obj.address, @account.change_address
      end

      def test_balance
        @utxo.stubs(:balance).returns(10_000)
        assert_equal 10_000, @account.balance
      end

      def test_history
        @transactions.stubs(:load).returns([{ id: "txid" }])
        assert_equal [{ id: "txid" }], @account.history
      end

      def test_update
        insight = mock
        insight.responds_like_instance_of(Insight)
        all_addresses = []
        @registry.stubs(:pluck_addresses).returns(all_addresses)
        Insight.stubs(:new)
               .with(BTC::Network.mainnet, @acc_balance_model, all_addresses)
               .returns(insight)
        tx = Struct.new(:txid, :used_addresses)
        page = Struct.new(:txs, :count, :from, :to)
        # updates in cycle. breaks if last page
        txs = [tx.new("0", ["0"]), tx.new("1", ["1"])]
        page1 = page.new(txs, 123, 0, 100)
        insight.expects(:transactions).with(0, 100).returns(page1)
        @transactions.expects(:compare_and_save).with(txs).returns(txs)
        @utxo.expects(:update_from_txs).with(txs)
        @registry.expects(:ensure_has_txs_mark).with(%w(0 1))
        page2 = page.new(txs, 123, 100, 200)
        insight.expects(:transactions).with(100, 200).returns(page2)
        @transactions.expects(:compare_and_save).with(txs).returns(txs)
        @utxo.expects(:update_from_txs).with(txs)
        @registry.expects(:ensure_has_txs_mark).with(%w(0 1))
        @registry.expects(:fill_gap_limit)
        @account.update
        # breaks if new_txs list less when page
        txs = [tx.new("tx0", ["0"]), tx.new("tx1", ["1"]), tx.new("tx2", ["2"])]
        page1 = page.new(txs, 123, 0, 100)
        insight.expects(:transactions).with(0, 100).returns(page1)
        @transactions.expects(:compare_and_save).with(txs)
                     .returns([txs[0]])
        @utxo.expects(:update_from_txs).with([txs[0]])
        @registry.expects(:ensure_has_txs_mark).with(["0"])
        @registry.expects(:fill_gap_limit)
        @account.update
      end

      def test_provide_keys
        acc = @acc_payments_ch_model
        account = Account.new(@container, acc)
        addresses = (0..5).map { |i| address_model(acc, 0, i) }
        addresses += (0..5).map { |i| address_model(acc, 1, i) }
        keychain = BTC::Keychain.new(xprv: acc.xprv)
        expected = addresses.map do |address|
          [address.address, keychain.derived_keychain(address.chain)
                                    .derived_key(address.index)]
        end
        @address_repo.expects(:find)
                     .with(addresses.map(&:address))
                     .returns(addresses)
        actual = account.send(:provide_keys, addresses.map(&:address), keychain)
        assert_equal actual.length, expected.length
        expected.each do |touple|
          same = actual.detect { |a| a.address == touple[0] }
          assert_equal same.key, touple[1]
        end
      end
    end
  end
end
