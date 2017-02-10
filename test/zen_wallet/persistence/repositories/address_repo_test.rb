require_relative "../test_helper"
module ZenWallet
  module Persistence
    class AddressRepoTest < RepoTest
      include AccModelMixin
      include WalletAttrsMixin
      include AddressMixin

      def setup
        super
        @sequel[:wallets].insert(@wallet_attrs)
        @sequel[:accounts].insert(@acc_balance_attrs)
        @finders = [WalletConstants::ID, AccConstants::Balance::INDEX]
      end

      def test_find_or_create
        assert_equal @addresses_models.first,
                     @repo.find_or_create(@addresses_models.first)
        assert_equal 1, @dataset.count
        assert_equal @addresses_models.first,
                     @repo.find_or_create(@addresses_models.first)
        assert_equal 1, @dataset.count
        assert_equal @addresses_attrs.first, @dataset.first
      end

      def test_pluck_address
        @dataset.import(@addresses_attrs.first.keys,
                        @addresses_attrs.map(&:values))
        @addrs = @addresses_models.map(&:address).reverse
        assert_equal @addrs, @repo.pluck_address(*@finders)
      end

      def test_gap_size
        assert_equal 0, @repo.gap_size(*@finders)
        @dataset.import(@addresses_attrs.first.keys,
                        @addresses_attrs.map(&:values))
        assert_equal 20, @repo.gap_size(*@finders)
        @dataset.where { index < 10 }.update(has_txs: true)
        assert_equal 10, @repo.gap_size(*@finders)
      end

      def test_free_receivers
        @dataset.import(@addresses_attrs.first.keys,
                        @addresses_attrs.map(&:values))
        assert_equal @addresses_models.reverse,
                     @repo.unused_recvs(*@finders)
      end

      def test_next_index
        assert_equal @repo.next_index(*@finders), 0
        @dataset.insert(@addresses_attrs.shift)
        assert_equal @repo.next_index(*@finders), 1
        @dataset.import(@addresses_attrs.first.keys,
                        @addresses_attrs.map(&:values))
        assert_equal @repo.next_index(*@finders), 20
      end
    end
  end
end
