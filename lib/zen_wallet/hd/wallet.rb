# frozen_string_literal: true
require "zen_wallet/crypto"
module ZenWallet
  module HD
    # bip44 wallet
    class Wallet < Abstract
      def_delegators :model, :id, :secured_xprv, :salt

      class Model < HD::Model
        attribute :id, Types::Strict::String
        attribute :secured_xprv, Types::Strict::String
        attribute :xpub, Types::Strict::String
        attribute :salt, Types::Strict::String
      end

      # Generate new keychain with empty id
      def self.generate(container, id, passphrase = "")
        keychain = BTC::Keychain.new(seed: SecureRandom.hex)
        hsh = {
          id: id,
          salt: SecureRandom.hex(16)
        }
        hsh[:secured_xprv] =
          Utils.encrypt(keychain.xprv, passphrase, hsh[:salt])
        new(container, keychain.xprv,  **hsh)
      end

      def extended_key
        xprv || xpub
      end

      def unlocked?
        private?
      end

      # def account(account_id)
      #   load_account(account_id)
      # end
      #
      # def ensure_account(account_id, forget_private_key: true)
      #   acc = load_account(account_id)
      #   return acc if acc
      #   acc || create_account(account_id, forget_private_key)
      # end

      def unlock(passphrase)
        @xprv = Utils.decrypt(@xprv_encrypted, passphrase, salt)
        @keychain = BTC::Keychain.new(xprv: @xprv)
        yield @keychain if block_given?
        remove_instance_variable("@xprv")
        @keychain = @keychain.public_keychain
      rescue OpenSSL::Cipher::CipherError
        raise "Wrong passphrase for decrypt wallet: #{id}"
      end
      #
      # def lock(passphrase, salt)
      #   @xprv_encrypted = Utils.encrypt(@xprv, passphrase, salt)
      #   nattrs = @struct.to_h.merge(xprv_encrypted: xprv_encrypted, salt: salt)
      #   @struct = self.class.struct.new(nattrs)
      # end

      # private
      #
      # def load_account(account_id)
      #   attrs = store.lookup(id, account_id)
      #   Account.new(self, **attrs) if attrs
      # end
      #
      # def create_account(account_id, forget_private_key = true)
      #   raise "Could not create account. Wallet is locked" unless unlocked?
      #   index = store.next_index(id)
      #   chain = keychain.bip44_keychain.bip44_account_keychain(index)
      #   key_str = forget_private_key ? chain.xpub : chain.xprv
      #   new_account =
      #     Account.new(self, id: account_id, index: index, extended_key: key_str)
      #   store.persist(new_account)
      #   new_account
      # end
    end
  end
end
