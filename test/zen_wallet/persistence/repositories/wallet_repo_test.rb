require_relative "../test_helper"
# require "zen_wallet/hd/wallet"
module ZenWallet
  module Persistence
    class WalletRepoTest < Minitest::Test
      include RepoMixin

      def setup
        @repo = @container.resolve("wallet_repo")
        @keychain = BTC::Keychain.new(seed: SecureRandom.hex)
        @attrs = { id: "id", xpub: @keychain.xpub,
                   secured_xprv: SecureRandom.hex(64),
                   salt: SecureRandom.hex(32) }
        @model = HD::Wallet::Model.new(@attrs)
        @dataset = @sequel[:wallets]
      end

      def test_find
        # ok
        @dataset.insert(@model.to_h)
        assert_equal @model, @repo[@model.id]
        # raise
        assert_nil @repo["NO"]
      end

      def test_create
        @repo.send(:create, @model)
        assert_equal @attrs, @dataset.first
      end

      def test_update
        @dataset.insert(@attrs.to_h)
        new_attrs = { id: "id", xpub: "0", secured_xprv: "1", salt: "2" }
        assert @repo.change("id", xpub: "0", secured_xprv: "1", salt: "2")
        assert_equal new_attrs, @dataset.first
      end
    end
  end
end
