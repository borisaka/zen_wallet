require_relative "../test_helper"
require "mixins/address"
module ZenWallet
  module Persistence
    class AddressRepoTest < RepoTest
      # include AccountMixin
      # include WalletAttrsMixin
      include AddressMixin

      def setup
        super
        @sequel[:wallets].insert(@wallet_attrs)
        @sequel[:accounts].insert(@acc_balance_attrs)
        @finders = [WalletConstants::ID, AccConstants::Balance::ID]
      end

      def test_create
        # Creates
        model = address_model(@acc_balance_model, 0, 0)
        @repo.create(model)
        assert_equal 1, @dataset.count
        # Finds
        assert_raises(ROM::SQL::UniqueConstraintError) do
          @repo.create(model)
        end
      end

      def test_find
        model = address_model(@acc_balance_model, 0, 0)
        assert_nil @repo.find(model.address)
        @dataset.insert(model.to_h)
        assert_equal model, @repo.find(model.address)
        # mutiselect
        addresses = []
        1.upto(10) do |i|
          address_obj = address_model(@acc_balance_model, 0, i)
          addresses << address_obj
          @dataset.insert(address_obj.to_h)
        end
        expected = addresses.shuffle[0..4]
        result = @repo.find(expected.map(&:address))
        assert_equal result.map(&:address).sort, expected.map(&:address).sort
      end

      def test_count
        5.times do |i|
          @dataset.insert address_attrs(@acc_balance_model, 0, i)
          @dataset.insert address_attrs(@acc_balance_model, 1, i)
          @dataset.insert address_attrs(@acc_balance_model, 0, i + 5,
                                        requested: true)
          @dataset.insert address_attrs(@acc_balance_model, 0, i + 10,
                                        has_txs: true, requested: true)
          @dataset.insert address_attrs(@acc_balance_model, 1, i + 5,
                                        has_txs: true)
        end
        assert_equal 15, @repo.count(*@finders, 0)
        assert_equal 10, @repo.count(*@finders, 1)
        assert_equal 10, @repo.count(*@finders, 0, requested: true)
        assert_equal 5, @repo.count(*@finders, 0, has_txs: true)
        assert_equal 5, @repo.count(*@finders, 1, has_txs: true)
      end

      def test_last_idx
        assert_nil @repo.last_idx(*@finders, 0)
        @dataset.insert address_attrs(@acc_balance_model, 0, 0)
        assert_equal 0, @repo.last_idx(*@finders, 0)
        assert_nil @repo.last_idx(*@finders, 1)
        @dataset.insert address_attrs(@acc_balance_model, 1, 0)
        assert_equal 0, @repo.last_idx(*@finders, 0)
      end

      def test_update_address
        attrs = (0..99).map { |i| address_attrs(@acc_balance_model, 0, i) }
        @dataset.import(attrs.first.keys, attrs.map(&:values))
        addresses = attrs.map { |hsh| hsh[:address] }
        @repo.update_addresses(addresses, requested: true, has_txs: true)
        records = @dataset.where(requested: true, has_txs: true).all
        assert_equal 100, records.length
      end

      def test_pluck_address
        ext_chain = (0..60).map { |i| address_attrs(@acc_balance_model, 0, i) }
        int_chain = (0..60).map { |i| address_attrs(@acc_balance_model, 1, i) }
        all = int_chain + ext_chain
        @dataset.import(all.first.keys, all.map(&:values))
        expected_ext = ext_chain.map { |h| h[:address] }.sort
        assert_equal expected_ext,
                     @repo.pluck_address(*@finders, 0, chain: 0).sort
      end

      def test_free_address
        attrs = (0..10).map { |i| address_attrs(@acc_balance_model, 0, i) }
        @dataset.import(attrs.first.keys, attrs.map(&:values))
        assert_equal attrs.last[:address], @repo.free_address(*@finders, 0)
        @dataset.where { index > 5 }.update(has_txs: true)
        assert_equal attrs[5][:address], @repo.free_address(*@finders, 0)
      end

      def test_find_account_ids
        @sequel[:accounts].insert(@acc_payments_attrs)
        attrs = [
          address_attrs(@acc_balance_model, 0, 0),
          address_attrs(@acc_payments_model, 0, 0),
          address_attrs(@acc_balance_model, 0, 1)
        ]
        attrs.each { |addr| @dataset.insert(addr) }
        addrs = attrs.map { |addr| addr[:address] }
        expected = [{ wallet_id: WalletConstants::ID, account_id: AccConstants::Balance::ID, address: addrs[0] },
                    { wallet_id: WalletConstants::ID, account_id: AccConstants::Payments::ID, address: addrs[1] },
                    { wallet_id: WalletConstants::ID, account_id: AccConstants::Balance::ID, address: addrs[2] }]
                   .sort_by { |o| o[:address] }
        assert_equal expected, @repo.find_account_ids(addrs).map(&:to_h)
      end

    end
  end
end
