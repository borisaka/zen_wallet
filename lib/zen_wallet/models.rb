require "dry-struct"
require_relative "types"
module ZenWallet
  module Models
    class Wallet < Dry::Struct
      attribute :id, Types::PKey
      attribute :secured_xprv, Types::Strict::String
      attribute :xpub, Types::Strict::String
      attribute :salt, Types::Strict::String
    end

    class Account < Dry::Struct
      attribute :wallet_id, Types::PKey
      attribute :id, Types::PKey
      attribute :index, Types::HDIndex
      attribute :xprv, Types::Strict::String.optional
      attribute :xpub, Types::Strict::String
    end

    class Address < Dry::Struct
      attribute :address, Types::PKey
      attribute :wallet_id, Types::PKey
      attribute :account_index, Types::HDIndex
      attribute :change, Types::HDChange
      attribute :index, Types::HDIndex
      attribute :has_txs, Types::Bool.default(false)
      attribute :requested, Types::Bool.default(false)
    end
  end
end
