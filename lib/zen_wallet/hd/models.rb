# frozen_string_literal: true
require "dry-struct"
require "zen_wallet/types"
module ZenWallet
  module HD
    # Structures of internal ZenWallet::HD objects
    # @api private
    module Models
      # @api private
      class Wallet < Dry::Struct
        attribute :id, Types::PKey
        attribute :secured_xprv, Types::Strict::String
        attribute :xpub, Types::Strict::String
        attribute :salt, Types::Strict::String
      end

      # @api private
      class Account < Dry::Struct
        attribute :wallet_id, Types::PKey
        attribute :id, Types::PKey
        attribute :index, Types::HDIndex
        attribute :xprv, Types::Strict::String.optional
        attribute :xpub, Types::Strict::String
      end

      # @api private
      class Address < Dry::Struct
        attribute :address, Types::PKey
        attribute :wallet_id, Types::PKey
        attribute :account_index, Types::HDIndex
        attribute :chain, Types::HDChange
        attribute :index, Types::HDIndex
        attribute :has_txs, Types::Bool.default(false)
        attribute :requested, Types::Bool.default(false)
      end
    end
  end
end
