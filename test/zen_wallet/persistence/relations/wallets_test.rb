require_relative "../test_helper"
module ZenWallet
  module Persistence
    class WalletsTest < Minitest::Test
      include RepoMixin

      def setup
        @relation = @container.resolve("rom").relation(:wallets)
        # @keychain = BTC::Keychain.new(seed: SecureRandom.hex)
        @attrs = { id: "id", xpub: SecureRandom.hex,
                   secured_xprv: SecureRandom.hex(64),
                   salt: SecureRandom.hex(32) }
        @model = HD::Wallet::Model.new(@attrs)
        @dataset = @sequel[:wallets]
      end

      def test_exists
        # if not exists
        refute @relation.exists?("0")
        # if exists
        @dataset.insert(@attrs)
        assert @relation.exists?("id")
      end


      def test_lookup
        # @relation.lookup("0")
        # binding.pry
        assert_raises(ROM::TupleCountMismatchError) { @relation.lookup("0") }
        @dataset.insert(@attrs)
        assert_equal @attrs, @relation.lookup(@model.id)
      end

    end
  end
end
