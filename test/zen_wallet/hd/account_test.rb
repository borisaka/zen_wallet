# frozen_string_literal: true
require_relative "test_helper"
require "zen_wallet/hd/account"
require "mixins/address"
# require "zen_wallet/insight"
module ZenWallet
  module HD
    class AccountsTest < HDTest
      include AddressMixin

      def setup
        super
        @address_repo = mock
        @container.register("address_repo", @address_repo)
        @model = @acc_balance_model
        @account = Account.new(@container, @model)
        @finders = [@model.wallet_id, @model.index]
        @registry = mock
        @registry.responds_like_instance_of(Account::Registry)
        @account.instance_variable_set("@registry", @registry)
        # @address_repo.stubs(:find_or_create).with()
      end

      def test_request_receive_addr
        @registry.expects(:fill_gap_limit).with(0)
        address_obj = address_model(@model, 0, 0)
        @registry.expects(:free_address).with(0).returns(address_obj)
        @registry.expects(:ensure_requested_mark).with(address_obj.address)
        assert_equal address_obj, @account.request_receive_addr
      end

      def test_fetch_balance
        all_addresses = (0..5).map { |i| gen_address(@model, 0, i) }
        @registry.stubs(:pluck_addresses).returns(all_addresses)
        insight = mock
        ZenWallet::Insight
          .expects(:new)
          .with(BTC::Network.mainnet, @acc_balance_model, all_addresses)
          .returns(insight)
        insight.stubs(:balance).returns "OK"
        assert_equal "OK", @account.fetch_balance
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
          assert_equal same.key,touple[1]
        end
      end
    end
  end
end
