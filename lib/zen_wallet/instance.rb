# frozen_string_literal: true
require "sequel"
require_relative "wallet"
require_relative "store"
module ZenWallet
  # Avoid requiring sequel in main namespace
  def self.instance(connection_string)
    store = Store.new(Sequel.connect(connection_string))
    Instance.new(store)
  end
  # Configured instance of ZenWallet
  class Instance
    def initialize(store)
      @store = store
    end

    def wallet(id)
      attrs = @store.load_wallet(id) || create_wallet(id, "")
      Wallet.new(@store, **attrs) if attrs
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
      wallet = Wallet.new(@store, **attrs)
      @store.create_wallet(wallet)
    end
  end
end
