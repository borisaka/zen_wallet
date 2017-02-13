# frozen_string_literal: true
require "btcruby"
require "zen_wallet/crypto"
require_relative "models"
require_relative "account"
module ZenWallet
  module HD
    # Wallet, what [not yet] implements BIP44 HD Root wallet
    # persists data in Repository, what must be resolved in IoC container
    # stored encrypted by wallet's passphrase
    #  copy of extended private key 'xprv'
    #  @see ZenWallet::Crypto
    # stored wallet accounts with trusted(with xprv persistends)
    #   and secured(with only xpub persistence)
    # @todo bip39 mnemonic generation
    # @todo import from existing seed/xprv
    class Wallet
      BadPassphraseError = Class.new(StandardError)
      # @param container [#resolve] IoC container with necessary object
      #   container must conain wallet_repo, account_repo
      #   and bitcoin_network [BTC::Network]
      # @param id [String] defined on client software unique id of
      #        user to authorization
      # @todo autogenerate id based on root keychain
      # @todo initialize already secured
      def initialize(container, id)
        @container = container
        @repo = container.resolve("wallet_repo")
        @account_repo = container.resolve("account_repo")
        @network = container.resolve("bitcoin_network")
        @model = @repo.find(id) || generate_and_persist(id, "")
        @keychain = BTC::Keychain.new(xpub: @model.xpub)
      end

      # unlocks master xprv
      # necessary for private_key or hardened derivation
      # and signification from untrusted accounts
      # @param passphrase passphrase to encryption
      # @raise [BadPassphraseError]
      # @yieldparam [BTC::Keychain] with extended private key
      def unlock(passphrase)
        xprv = Crypto.decrypt(@model.secured_xprv, passphrase, @model.salt)
        prv_keychain = BTC::Keychain.new(xprv: xprv)
        return yield prv_keychain if block_given?
      rescue OpenSSL::Cipher::CipherError
        raise BadPassphraseError, "Wrong passphrase for decrypt wallet"
      end

      # @todo
      #  @example Pay from normal account
      #    wallet.unlock_account(passphrase, "money") do |keychain|
      #      account.spend(outs, wd, keychain)
      #    end
      def unlock_account(passphrase, account_id)
      end

      # reencrypt master key with new user passphrase
      # @param current_passphrase [String] current passphrase
      # @param passphrase [String] new passphrase
      # @return true if passphrase changed succesfully
      # @raise [BadPassphraseError] (@see #unlock)
      def change_passphrase(current_passphrase, passphrase)
        unlock(current_passphrase) do |keychain|
          salt = SecureRandom.hex(16)
          secured_xprv = Crypto.encrypt(keychain.xprv, passphrase, salt)
          new_model =
            Models::Wallet.new(id: @model.id, secured_xprv: secured_xprv,
                               xpub: @model.xpub, salt: salt)
          @repo.update_passphrase(new_model)
          @model = new_model
        end
        true
      end

      # load account by given id
      # @param id [String]
      # @return [Account] if account stored in repo
      # @return nil if it does not exists
      def account(id)
        account_model = @account_repo.find(@model.id, id)
        return Account.new(@container, account_model) if account_model
      end

      # open BIP44 account (new or existed)
      # @param id [String] user given identificator for account
      # @param passphrase [String] passphrase to unlock wallet
      # @param trusted [Boolean] (false) whether keep xprv of account or not
      # trusted may be used for service e.g. subscribtions
      # account creation required wallet xprv wherever is trusted account or not
      # because BIP44 spec asserts to hardened keys derivation at this level
      def open_account(id, passphrase, trusted = false)
        unlock(passphrase) do |prv_keychain|
          account_model = build_account(id, prv_keychain, trusted)
          Account.new(@container, @account_repo.persist(account_model))
        end
      end

      private

      # new wallet creation
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

      def account_keychain(index, prv_keychain)
        prv_keychain.bip44_keychain(network: @network)
                    .bip44_account_keychain(index)
      end

      def build_account(id, prv_keychain, trusted)
        index = @account_repo.next_index(@model.id, id)
        acc_keychain = account_keychain(index, prv_keychain)
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
