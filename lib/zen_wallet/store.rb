# frozen_string_literal: true
require "money-tree"
require "dry-monads"
require_relative "utils"
module ZenWallet
  # Stores wallets and addresses in database
  class Store
    def self.setup(sequel)
      Sequel.extension :migration
      Sequel::Migrator.run(sequel, File.join(__dir__, "migrations"))
    end

    def initialize(sequel)
      @sequel = sequel
    end

    def create_wallet(wallet)
      attrs = { id: wallet.id, encrypted_seed: wallet.encrypted_seed,
                salt: wallet.salt, public_seed: wallet.public_seed }
      @sequel[:wallets].insert(**attrs) && attrs
    end

    def load_wallet(id)
      @sequel[:wallets].where(id: id).first
    end

    def create_account(account)
      order = next_account_index(account.wallet.id)
      attrs = { wallet_id: account.wallet.id, id: account.id, order: order,
                address: account.address, private_key: account.private_key,
                public_key: account.public_key }
      @sequel[:accounts].insert(**attrs) && attrs
    end

    def load_account(wallet_id, id)
      @sequel[:accounts].where(id: id, wallet_id: wallet_id).first
    end

    def next_account_index(wallet_id)
      @sequel[:accounts].where(wallet_id: wallet_id).max(:order).to_i + 1
    end

    def set_account_private_key(wallet_id, id, new_prvate_key)
      @sequel[:accounts].where(wallet_id: wallet_id, id: id)
                        .update(private_key: new_prvate_key)
    end
  end
end
