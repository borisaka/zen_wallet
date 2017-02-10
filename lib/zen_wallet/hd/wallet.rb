# frozen_string_literal: true
require "btcruby"
require "zen_wallet/crypto"
require "zen_wallet/models"
require_relative "account"
module ZenWallet
  module HD
    # bip44 wallet
    class Wallet
      # Generate new keychain with empty id
      attr_reader :keychain, :model
      BadPassphraseError = Class.new(StandardError)
      def initialize(container, id)
        @container = container
        @repo = container.resolve("wallet_repo")
        @account_repo = container.resolve("account_repo")
        @address_repo = container.resolve("address_repo")
        @network = container.resolve("bitcoin_network")
        @model = @repo.find(id) || generate_and_persist(id, "")
        @keychain = BTC::Keychain.new(xpub: @model.xpub)
      end

      # @yields BTC::Keychain with private key
      def unlock(passphrase)
        xprv = Crypto.decrypt(@model.secured_xprv, passphrase, @model.salt)
        prv_keychain = BTC::Keychain.new(xprv: xprv)
        return yield prv_keychain if block_given?
      rescue OpenSSL::Cipher::CipherError
        raise BadPassphraseError, "Wrong passphrase for decrypt wallet"
      end

      def change_passphrase(current_passphrase, passphrase = "")
        unlock(current_passphrase) do |keychain|
          salt = SecureRandom.hex(16)
          secured_xprv = Crypto.encrypt(keychain.xprv, passphrase, salt)
          new_model =
            Models::Wallet.new(id: @model.id, secured_xprv: secured_xprv,
                               xpub: @model.xpub, salt: salt)
          @repo.update_passphrase(new_model)
          @model = new_model
        end
      end

      def account(id)
        account_model = @account_repo.find(@model.id, id)
        return Account.new(@container, account_model) if account_model
      end

      # Deterministic account creation
      def open_account(id, passphrase, trusted = false)
        unlock(passphrase) do |prv_keychain|
          account_model = build_account(id, prv_keychain, trusted)
          Account.new(@container, @account_repo.persist(account_model))
        end
      end

      private

      def generate_and_persist(id, passphrase)
        keychain = BTC::Keychain.new(seed: SecureRandom.hex, network: @network)
        salt = SecureRandom.hex(16)
        @model = Models::Wallet.new(
          id: id,
          secured_xprv: Crypto.encrypt(keychain.xprv, passphrase, salt),
          salt: salt,
          xpub: keychain.xpub
        )
        @repo.create(@model)
        @model
      end

      def build_account(id, prv_keychain, trusted)
        index = @account_repo.next_index(@model.id, id)
        acc_keychain = prv_keychain.bip44_keychain(network: @network)
                                   .bip44_account_keychain(index)
        xprv = trusted ? acc_keychain.xprv : nil
        Models::Account.new(
          wallet_id: @model.id,
          id: id,
          index: index,
          xprv: xprv,
          xpub: acc_keychain.xpub
        )
      end
    end
  end
end
