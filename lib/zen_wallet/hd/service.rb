# frozen_string_literal: true
require "sequel"
require "zen_wallet/persistence"
require_relative "wallet"
module ZenWallet
  # Avoid requiring sequel in main namespace
  def self.hd_wallet_service(connection_string)
    store = ZenWallet::Persistence.connect(connection_string)
    HD::Service.new(store)
  end

  module HD
    # Service what control wallets
    class Service
      def initialize(store)
        @store = store
      end

      # Connect to wallet idempotently
      def wallet(id)
        attrs = @store.wallets.lookup(id) || create_wallet(id, "")
        Wallet.new(@store.accounts, **attrs) if attrs
      end

      def update_wallet_passphrase(id, passphrase, new_passphrase)
        wallet = wallet(id)
        seed = Utils.decrypt(wallet.encrypted_seed, passphrase, wallet.salt)
        new_salt = SecureRandom.hex(16)
        reencrypted_seed = Utils.encrypt(seed, new_passphrase, new_salt)
        @store.wallets.update_encrypted_seed(id, reencrypted_seed, new_salt)
      end

      private

      def create_wallet(id, passphrase)
        attrs = { id: id }
        attrs[:salt] = SecureRandom.hex(16)
        master = MoneyTree::Master.new
        attrs[:public_seed] = master.to_bip32
        serialized_seed = master.to_bip32(:private)
        attrs[:encrypted_seed] =
          Utils.encrypt(serialized_seed, passphrase, attrs[:salt])
        attrs[:chain_code] = master.chain_code
        wallet = Wallet.new(@store.accounts, **attrs)
        @store.wallets.persist(wallet)
      end
    end
  end
end
