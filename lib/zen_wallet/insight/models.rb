require "dry-struct"
require "zen_wallet/types"
require_relative "models/balance"
module ZenWallet
  class Insight
    # Structures for bitcore insight api result
    # @api private
    module Models
      include ZenWallet::CommonStructs
      # Bitcoin Transaction Input
      class TxIn < Dry::Struct
        attribute :txid, Types::Strict::String
        attribute :vout, Types::Strict::Int
        attribute :n, Types::Strict::Int
        attribute :address, Types::Strict::String
        attribute :amount, Types::Strict::Int
      end

      # Bitcoin Transaction Output
      class TxOut < Dry::Struct
        attribute :n, Types::Strict::Int
        attribute :amount, Types::Strict::Int
        attribute :address, Types::Strict::String
        attribute :type, Types::Strict::String
        attribute :script, Types::Strict::String
      end

      # Bitcoin Tx
      class Tx < Dry::Struct
        attribute :txid, Types::Strict::String
        attribute :confirmations, Types::Strict::Int
        attribute :time, Types::Strict::Time
        attribute :blocktime, Types::Strict::Time.optional
        attribute :inputs, Types::Strict::Array.member(TxIn)
        attribute :outputs, Types::Strict::Array.member(TxOut)
      end

      # Bitcore Insight Page with transaction
      class TxPage < Dry::Struct
        attribute :txs, Types::Strict::Array.member(Tx)
        attribute :total, Types::Strict::Int
        attribute :from, Types::Strict::Int
        attribute :to, Types::Strict::Int
      end

      # Extended ZenWallet transaction wiew
      class AccountTx < Tx
        attribute :wallet, Types::PKey
        attribute :account, Types::PKey
        attribute :amount, Types::Strict::Int
        attribute :direction, Types::TxDirection
        attribute :main_address, Types::Strict::String
        attribute :addresses, Types::Strict::Array.member(Models::AddressAmount)
        attribute :fees, Types::Strict::Int
        attribute :peer_main_address, Types::Strict::String.optional
        attribute :peer_amount, Types::Strict::Int.default(0)
        attribute :peer_addresses,
                  Types::Strict::Array.member(Models::AddressAmount)
      end
    end
  end
end
