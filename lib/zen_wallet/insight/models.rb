require "dry-struct"
module ZenWallet
  module Insight
    module Models
      module Types
        include Dry::Types.module
        Def = Dry::Types::Definition
        Timestamp = Def.new(::Time).constructor { |i| Time.at(i) }
        # @todo define validators
        BTC = Module.new
        BTC::TID = Strict::String
        BTC::Address = Strict::String
      end

      class TxIn < Dry::Struct
        attribute :txid, Types::BTC::TID
        attribute :vout, Types::Strict::Int
        attribute :n, Types::Strict::Int
        attribute :address, Types::BTC::Address
        attribute :satoshis, Types::Strict::Int
      end

      class TxOut < Dry::Struct
        attribute :n, Types::Strict::Int
        attribute :satoshis, Types::Strict::Int
        attribute :address, Types::BTC::Address
      end

      class Tx < Dry::Struct
        attribute :txid, Types::BTC::TID
        attribute :confirmations, Types::Strict::Int
        attribute :input_sat, Types::Strict::Int
        attribute :output_sat, Types::Strict::Int
        attribute :time, Types::Strict::DateTime
        attribute :blocktime, Types::Strict::DateTime.optional
        attribute :fees, Types::Strict::Int
        attribute :inputs, Types::Strict::Array.member(TxIn)
        attribute :outputs, Types::Strict::Array.member(TxOut)
      end
    end
  end
end
