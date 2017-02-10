require_relative "../test_helper"
module ZenWallet
  module Persistence
    class AccountsTest < RelationTest
      include WalletAttrsMixin
      include AcctAttrsMixin

      def setup
        super
        @sequel[:wallets].insert(@wallet_attrs)
        @filter_args = [AccConstants::Balance::WALLET_ID,
                        AccConstants::Balance::NAME]
      end

      def test_exists
        refute @relation.exists?("0", "0")
        @dataset.insert(@acc_balance_attrs)
        assert @relation.exists?(*@filter_args)
      end

      def test_lookup
        assert_nil @relation.lookup("0", "0")
        @dataset.insert(@acc_balance_attrs)
        assert_equal @acc_balance_attrs, @relation.lookup(*@filter_args)
      end

      def test_next_free_id
        assert_equal 1, @relation.next_free_id(AccConstants::Balance::WALLET_ID)
        @dataset.insert(@acc_balance_attrs)
        assert_equal 2, @relation.next_free_id(AccConstants::Balance::WALLET_ID)
        @dataset.insert(@acc_payments_attrs)
        assert_equal 3, @relation.next_free_id(AccConstants::Balance::WALLET_ID)
      end
    end
  end
end
