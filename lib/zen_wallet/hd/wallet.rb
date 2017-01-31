# frozen_string_literal: true
require "dry-equalizer"
require "dry-initializer"
require "dry-types"
require "money-tree"
require "zen_wallet/utils"
require_relative "account"
module ZenWallet
  module HD
    class Wallet
      extend Dry::Initializer::Mixin
      include Dry::Equalizer(:id, :encrypted_seed, :public_seed, :salt)
      param  :store
      option :id
      option :encrypted_seed
      option :public_seed
      option :salt

      def account(account_id)
        load_account(account_id) || create_account(account_id)
      end

      def accounts
        store.by_wallet(id).map { |attrs| Account.new(self, **attrs) }
      end

      # def account_by_address(address)
      #   Account.new(self, store.by_wallet(id, address: address).first)
      # end

      def unlock(passphrase)
        seed = Utils.decrypt(encrypted_seed, passphrase, salt)
        unlocked = MoneyTree::Master.from_bip32(seed)
        yield unlocked if block_given?
        true
      rescue OpenSSL::Cipher::CipherError
        false
      end

      def master
        @master ||= MoneyTree::Master.from_bip32(public_seed)
      end

      def private_key_for(account_id, passphrase = "")
        acc = account(account_id)
        key = nil
        unlock(passphrase) do |master|
          node = master.node_for_path("m/44/0/#{acc.order}")
          key = node.private_key.to_wif
        end
        key
      end

      def derive_private_key(account_id, passphrase = "")
        pk = private_key_for(account_id, passphrase)
        store.set_private_key(id, account_id, pk)
        true
      end

      private

      def load_account(account_id)
        attrs = store.lookup(id, account_id)
        Account.new(self, **attrs) if attrs
      end

      def create_account(account_id)
        order = store.next_index(id)
        node = master.node_for_path("m/44/0/#{order}")
        new_account = Account.new(self,
                                  id: account_id,
                                  order: order,
                                  public_key: node.public_key.key,
                                  private_key: node.private_key&.to_wif,
                                  address: node.to_address)
        store.persist(new_account)
        new_account
      end
    end
  end
end
