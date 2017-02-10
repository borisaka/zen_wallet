require_relative "../test_helper"
module ZenWallet
  module Persistence
    class WalletsTest < RelationTest
      include WalletAttrsMixin

      def test_exists
        # if not exists
        refute @relation.exists?("0")
        # if exists
        @dataset.insert(@wallet_attrs)
        assert @relation.exists?(WalletConstants::ID)
      end

      def test_lookup
        assert_nil @relation.lookup("0")
        @dataset.insert(@wallet_attrs)
        assert_equal @wallet_attrs, @relation.lookup(WalletConstants::ID)
      end
    end
  end
end
