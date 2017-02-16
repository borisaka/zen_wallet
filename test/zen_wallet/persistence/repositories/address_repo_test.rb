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
        @finders = [WalletConstants::ID, AccConstants::Balance::INDEX]
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

      def test_first_by
        assert_nil @repo.first_by(*@finders, 0)
        attrs, models = [], []
        attrs << address_attrs(@acc_balance_model, 0, 0,
                               has_txs: true,
                               requested: true)
        attrs << address_attrs(@acc_balance_model, 0, 1, requested: true)
        attrs << address_attrs(@acc_balance_model, 0, 2)
        attrs.each do |at|
          @dataset.insert(at)
          models << HD::Models::Address.new(at)
        end
        assert_equal models[0], @repo.first_by(*@finders, 0)
        assert_equal models[1], @repo.first_by(*@finders, 0, has_txs: false)
        assert_equal models[2], @repo.first_by(*@finders, 0, requested: false)
      end

      def test_update
        attrs = address_attrs(@acc_balance_model, 0, 0)
        @dataset.insert(attrs)
        @repo.update(attrs[:address], requested: true, has_txs: true)
        rec = @dataset.first
        assert rec[:requested]
        assert rec[:has_txs]
      end

      def test_pluck_address
        # ext, int = [], []
        ext_chain = (0..60).map { |i| address_attrs(@acc_balance_model, 0, i) }
        int_chain = (0..60).map { |i| address_attrs(@acc_balance_model, 1, i) }
        all = int_chain + ext_chain
        @dataset.import(all.first.keys, all.map(&:values))
        # all.each { |addr| @dataset.insert(addr.to_h) }
        limited = int_chain.map { |attrs| attrs[:address] }.sort.reverse[0..39]
        w_offset = ext_chain.map { |attrs| attrs[:address] }
                            .sort.reverse[39..-1]
        assert_equal limited, @repo.pluck_address(*@finders, 0, chain: 0).sort
        assert_equal w_offset,
                     @repo.pluck_address(*@finders, 40, chain: 1).sort
      end

    end
  end
end
