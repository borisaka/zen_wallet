require "dry-struct"
module ZenWallet
  class Insight
    module Models
      module Types
        include Dry::Types.module
      end

      class TxIn < Dry::Struct
        attribute :txid, Types::Strict::String
        attribute :vout, Types::Strict::Int
        attribute :n, Types::Strict::Int
        attribute :address, Types::Strict::String
        attribute :satoshis, Types::Strict::Int
      end

      class TxOut < Dry::Struct
        attribute :n, Types::Strict::Int
        attribute :satoshis, Types::Strict::Int
        attribute :address, Types::Strict::String
        attribute :type, Types::Strict::String
        attribute :script, Types::Strict::String
      end

      class Tx < Dry::Struct
        attribute :txid, Types::Strict::String
        attribute :confirmations, Types::Strict::Int
        attribute :time, Types::Strict::Time
        attribute :blocktime, Types::Strict::Time.optional
        attribute :inputs, Types::Strict::Array.member(TxIn)
        attribute :outputs, Types::Strict::Array.member(TxOut)
      end

      class TxPage < Dry::Struct
        attribute :txs, Types::Strict::Array.member(Tx)
        attribute :total, Types::Strict::Int
        attribute :from, Types::Strict::Int
        attribute :to, Types::Strict::Int
      end

      class Utxo < Dry::Struct
        attribute :address,  Types::Strict::String
        attribute :txid, Types::Strict::String
        attribute :vout, Types::Strict::Int
        attribute :satoshis, Types::Strict::Int
        attribute :script, Types::Strict::String
      end
    end
  end
end
