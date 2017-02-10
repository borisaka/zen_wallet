# frozen_string_literal: true
require "test_helper"
require "zen_wallet/hd/wallet"
module ZenWallet
  module HD
    class WalletTest < Minitest::Test
      include WalletModelMixin
      include AccModelMixin

      def setup
        @container = Dry::Container.new
        @repo = mock
        @account_repo = mock
        @container.register("wallet_repo", @repo)
        @container.register("account_repo", @account_repo)
        @container.register("address_repo", @mock)
        @container.register("bitcoin_network", BTC::Network.mainnet)
        @prv_keychain = BTC::Keychain.new(seed: WalletConstants::RANDOM_SEED)
        @pub_keychain = @prv_keychain.public_keychain
        @repo.stubs(:find).with("id").returns(@wallet_model)
        @wallet = Wallet.new(@container, "id")
      end

      def test_initialize__create
        @repo.expects(:find).with(WalletConstants::ID).returns(nil)
        Wallet.any_instance.expects(:generate_and_persist)
              .with(WalletConstants::ID, WalletConstants::PASSPHRASE)
              .returns(@wallet_model)
        wallet = Wallet.new(@container, "id")
        assert_same @repo, wallet.instance_variable_get("@repo")
        assert_same @account_repo, wallet.instance_variable_get("@account_repo")
        assert_same @wallet_model, wallet.instance_variable_get("@model")
        assert_equal @pub_keychain, wallet.instance_variable_get("@keychain")
      end

      def test_initialize__load
        @repo.expects(:find).with(WalletConstants::ID).returns(@wallet_model)
        wallet = Wallet.new(@container, WalletConstants::ID)
        assert_same @repo, wallet.instance_variable_get("@repo")
        assert_same @account_repo, wallet.instance_variable_get("@account_repo")
        assert_same @wallet_model, wallet.instance_variable_get("@model")
        assert_equal @pub_keychain, wallet.instance_variable_get("@keychain")
      end

      def test_unlock
        result = @wallet.unlock(WalletConstants::PASSPHRASE) do |chain|
          assert_equal @prv_keychain, chain
          assert_equal @pub_keychain, @wallet.instance_variable_get("@keychain")
          "OK"
        end
        assert_equal "OK", result
        # raises if bad passphrase
        assert_raises(Wallet::BadPassphraseError) { @wallet.unlock("NO") }
      end

      def test_change_passphrase
        SecureRandom.expects(:hex).with(16)
                    .returns(WalletConstants::CH_SALT)
        @repo.expects(:update_passphrase).with(equals(@wallet_ch_model))
        @wallet.change_passphrase(WalletConstants::PASSPHRASE,
                                  WalletConstants::CH_PASSPHRACE)
        assert_equal @wallet_ch_model, @wallet.instance_variable_get("@model")
      end

      def test_generate_and_persist
        SecureRandom.expects(:hex).returns(WalletConstants::RANDOM_SEED)
        SecureRandom.expects(:hex).with(16).returns(WalletConstants::SALT)
        @repo.expects(:create).with(equals(@wallet_model))
        @wallet.send(:generate_and_persist,
                     WalletConstants::ID,
                     WalletConstants::PASSPHRASE)
        assert_equal @wallet_model, @wallet.instance_variable_get("@model")
      end

      def test_account
        @account_repo.expects(:find)
                     .with(WalletConstants::ID, AccConstants::Balance::ID)
                     .returns(@acc_balance_model)
        acc = @wallet.account(AccConstants::Balance::ID)
        assert_instance_of Account, acc
        assert_equal @acc_balance_model, acc.instance_variable_get("@model")
      end

      def test_open_account
        @account_repo.stubs(:next_index)
                     .with(WalletConstants::ID, AccConstants::Payments::ID)
                     .returns(AccConstants::Payments::INDEX)
        # untrusted
        create_account_assertions(@acc_payments_model, false)
        # trusted
        create_account_assertions(@acc_payments_ch_model, true)
      end

      private

      def create_account_assertions(model, trusted)
        @account_repo.expects(:persist)
                     .with(equals(model))
                     .returns(model)
        res_acc = @wallet.open_account(AccConstants::Payments::ID,
                                       WalletConstants::PASSPHRASE,
                                       trusted)
        assert_instance_of Account, res_acc
        assert_equal model, res_acc.instance_variable_get("@model")
      end
    end
  end
end
