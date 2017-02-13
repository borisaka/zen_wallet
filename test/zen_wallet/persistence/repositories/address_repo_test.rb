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
        ext_chain = (0..4).map { |i| address_model(@acc_balance_model, 0, i) }
        int_chain = (0..4).map { |i| address_model(@acc_balance_model, 1, i) }
        all = int_chain + ext_chain
        all.each { |addr| @dataset.insert(addr.to_h) }
        assert_equal all.map(&:address).sort,
                     @repo.pluck_address(*@finders).sort
        assert_equal ext_chain.map(&:address).sort,
                     @repo.pluck_address(*@finders, chain: 0).sort
      end

      # def test_next_recv
      #   # First address anyway
      #   @dataset.import(@addresses_attrs.first.keys,
      #                   @addresses_attrs.map(&:values))
      #   assert_equal @addresses_models.first, @repo.next_recv(*@finders, true)
      #   assert_equal @addresses_models.first, @repo.next_recv(*@finders, false)
      #   # Ignores used anyway
      #   @dataset.where { index < 5 }.update(has_txs: true)
      #   assert_equal @addresses_models[5], @repo.next_recv(*@finders, true)
      #   assert_equal @addresses_models[5], @repo.next_recv(*@finders, false)
      #   # Ignores requested if flag required
      #   @dataset.where { index < 9 }.update(requested: true)
      #   assert_equal @addresses_models[5], @repo.next_recv(*@finders, false)
      #   assert_equal @addresses_models[9], @repo.next_recv(*@finders, true)
      # end
      #
      # def test_gap_size
      #   # All in gap
      #   assert_equal 0, @repo.gap_size(*@finders)
      #   @dataset.import(@addresses_attrs.first.keys,
      #                   @addresses_attrs.map(&:values))
      #   assert_equal 20, @repo.gap_size(*@finders)
      #   # Used still in gap
      #   @dataset.where { index < 10 }.update(requested: true)
      #   assert_equal 20, @repo.gap_size(*@finders)
      #   # Used is not
      #   @dataset.where { index < 10 }.update(has_txs: true)
      #   assert_equal 10, @repo.gap_size(*@finders)
      # end
      #
      # def test_next_index
      #   assert_equal @repo.next_index(*@finders), 0
      #   @dataset.insert(@addresses_attrs.shift)
      #   assert_equal @repo.next_index(*@finders), 1
      #   @dataset.import(@addresses_attrs.first.keys,
      #                   @addresses_attrs.map(&:values))
      #   assert_equal @repo.next_index(*@finders), 20
      # end
    end
  end
end
