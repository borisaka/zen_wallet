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
        constructor_type :permissive
        attribute :txid, Types::Coercible::String
        attribute :vout, Types::Coercible::Int
        attribute :n, Types::Coercible::Int
        attribute :address, Types::Coercible::String
        attribute :amount, Types::Coercible::Int
      end

      # Bitcoin Transaction Output
      class TxOut < Dry::Struct
        constructor_type :permissive
        attribute :n, Types::Coercible::Int
        attribute :amount, Types::Coercible::Int
        attribute :address, Types::Coercible::String
        attribute :type, Types::Coercible::String
        attribute :script, Types::Coercible::String
      end

      # Bitcoin Tx
      class Tx < Dry::Struct
        constructor_type :permissive
        attribute :txid, Types::Coercible::String
        attribute :confirmations, Types::Coercible::Int
        attribute :confirmed, Types::Strict::Bool
        attribute :time, Types::Strict::Time
        attribute :blocktime, Types::Strict::Time.optional
        attribute :blockhash, Types::Coercible::String.optional
        attribute :inputs, Types::Coercible::Array.member(TxIn)
        attribute :outputs, Types::Coercible::Array.member(TxOut)
        attribute :fees, Types::Coercible::Int
        attribute :amount_in, Types::Coercible::Int
        attribute :amount_out, Types::Coercible::Int
      end

      class AccountTxDetail < Dry::Struct
        attribute :inputs, Types::Coercible::Array.member(TxIn)
        attribute :outputs, Types::Coercible::Array.member(TxOut)
      end

      class AccountTx < Tx
        constructor_type :permissive
        attribute :wallet, Types::PKey
        attribute :account, Types::Coercible::Int
        attribute :total, Types::Strict::Int
        attribute :main_address, Types::Coercible::String
        attribute :out_address, Types::Coercible::String
        attribute :used_addresses,
                  Types::Coercible::Array.member(Types::Coercible::String)
        attribute :account_detail, AccountTxDetail
      end

      # # Bitcore Insight Page with transaction
      class TxPage < Dry::Struct
        attribute :txs, Types::Strict::Array.member(AccountTx)
        attribute :count, Types::Coercible::Int
        attribute :from, Types::Coercible::Int
        attribute :to, Types::Coercible::Int
      end

      # Extended ZenWallet transaction wiew

    end
  end
end
