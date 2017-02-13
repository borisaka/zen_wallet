require_relative "../test_helper"
module ZenWallet
  module Persistence
    class WalletRepoTest < RepoTest
      include WalletModelMixin

      def setup
        super
        @rel_accounts = mock
      end

      def test_find
        # ok
        @dataset.insert(@wallet_model.to_h)
        assert_equal @wallet_model, @repo.find(WalletConstants::ID)
        assert_nil @repo.find("NO")
      end

      def test_create
        @repo.create(@wallet_model)
        assert_equal @wallet_attrs, @dataset.first
      end

      def test_update_passphrase
        # ok
        fake_attrs = { id: "fid", secured_xprv: "fxprv",
                       xpub: "fxpub", salt: "fsalt" }
        @dataset.insert(fake_attrs)
        @dataset.insert(@wallet_attrs.to_h)
        @repo.update_passphrase(@wallet_ch_model)
        # update needed id
        assert_equal @wallet_ch_attrs,
                     @dataset.where(id: WalletConstants::ID).first
        # not affect wrong rows
        assert_equal fake_attrs, @dataset.where(id: "fid").first
      end

      def test_internal
        @dataset.insert(@wallet_attrs.to_h)
        wrong_model =
          HD::Models::Wallet.new(@wallet_attrs.merge(secured_xprv: "spv"))
        assert_raises(WalletRepo::UnpermittedUpdate) do
          @repo.update_passphrase(wrong_model)
        end
        assert_raises(WalletRepo::UnpermittedUpdate) do
          @repo.update_passphrase(@wallet_model)
        end
        assert_raises(NoMethodError) { @repo.update("id", "xxx") }
      end
    end
  end
end
