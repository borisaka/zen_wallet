require_relative "../test_helper"
module ZenWallet
  module Persistence
    class AccountRepoTest < RepoTest
      include AccModelMixin
      include WalletAttrsMixin
      def setup
        super
        @sequel[:wallets].insert(@wallet_attrs)
      end

      def test_find
        @dataset.insert(@acc_balance_model.to_h)
        assert_equal @acc_balance_model,
                     @repo.find(AccConstants::Balance::WALLET_ID,
                                AccConstants::Balance::ID)
        assert_nil @repo.find("0", "0")
      end

      def test_next_index
        # First acc_id
        assert_equal 0, @repo.next_index(AccConstants::Balance::WALLET_ID,
                                         AccConstants::Balance::ID)
        # If another wallet present
        @sequel[:wallets].insert(@wallet_attrs.merge(id: "id2"))
        @dataset.insert(@acc_balance_attrs.merge(wallet_id: "id2"))
        assert_equal 0, @repo.next_index(AccConstants::Balance::WALLET_ID,
                                         AccConstants::Balance::ID)
        # next index for next wallet
        @dataset.insert(@acc_balance_attrs)
        assert_equal 1, @repo.next_index(AccConstants::Balance::WALLET_ID,
                                         AccConstants::Payments::ID)
        # one more time
        @dataset.insert(@acc_payments_attrs)
        assert_equal 2, @repo.next_index(AccConstants::Balance::WALLET_ID,
                                         "UNUSED")
        # index for balance still not changed
        assert_equal 0, @repo.next_index(AccConstants::Balance::WALLET_ID,
                                         AccConstants::Balance::ID)
      end

      def test_persist
        # creating
        @repo.persist(@acc_payments_model)
        assert_equal @acc_payments_attrs, @dataset.first
        # changing xprv
        assert_equal @acc_payments_ch_model,
                     @repo.persist(@acc_payments_ch_model)
        assert_equal @acc_payments_ch_attrs, @dataset.first
      end
    end
  end
end
