# frozen_string_literal: true
require "dry-equalizer"
require "dry-initializer"
require "dry-types"
require "money-tree"
require_relative "utils"
require_relative "account"
module ZenWallet
  class Wallet
    extend Dry::Initializer::Mixin
    include Dry::Equalizer(:encrypted_seed, :public_seed)
    param :store
    option :id
    option :encrypted_seed
    option :public_seed
    option :salt

    def account(account_id)
      load_account(account_id) || create_account(account_id)
    end

    def unlock(passphrase)
      seed = Utils.decrypt(encrypted_seed, passphrase, salt)
      unlocked = MoneyTree::Master.from_bip32(seed)
      yield unlocked
    end

    def master
      @master ||= MoneyTree::Master.from_bip32(public_seed)
    end

    def derive_private_key(account_id, passphrase: "")
      stored_account = store.load_account(id, account_id)
      unlock(passphrase) do |master|
        node = master.node_for_path("m/44/0/#{stored_account[:order]}")
        store.set_account_private_key(id, account_id, node.private_key.key)
      end
    end

    private

    def load_account(account_id)
      attrs = store.load_account(id, account_id)
      Account.new(self, **attrs) if attrs
    end

    def create_account(account_id)
      order = store.next_account_index(id)
      node = master.node_for_path("m/44/0/#{order}")
      new_account = Account.new(self,
                                id: account_id,
                                public_key: node.public_key.key,
                                private_key: node.private_key&.key,
                                address: node.to_address)
      store.create_account(new_account)
      new_account
    end
  end
end
