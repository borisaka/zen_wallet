require "dry-struct"
require_relative "transaction"
# require
module ZenWallet
  class Insight
    class Balance
      extend Forwardable
      def_delegators :@model, :amount, :address, :transactions, :utxo

      class Schema < Dry::Struct
        attribute :wallet, Types::PKey
        attribute :account, Types::PKey
        attribute :amount, Types::Strict::Int
        attribute :addresses, Types::Strict::Array.member(AddressBalance)
        attribute :transactions, Types::Strict::Array.member(Transaction)
        attribute :utxo, Types::Strict::Array.member(Models::Utxo)
      end

      def initialize(account, network)
        @account = account
        @wallet = @account.model.id
        @amount = 0
        @addresses = []
        @transactions = []
        @utxo = []
        @network = network
        build_model
      end

      # Update balance
      def  fetch
        @addresses = @account.pluck_addresses
        insight = Insight.new(@account, @network)
        transactions = insight.transactions
        @transactions = @model.transactions + transactions
        @amount = @transactions.map(&:amount).reduce(&:+)
        @utxo = insight.utxo
        group = @transactions.map(&:address_details).flatten.group_by(&:address)
        @addresses = group.map do |k, v|
          AddressBalance.new(address: k, amount: v.map(&:amount).reduce(&:+))
        end
        build_model
      end

      private

      def build_model
        @model = Schema.new(wallet: @wallet,
                            account: @account.model.id,
                            amount: @amount,
                            addresses: @addresses,
                            transactions: @transactions,
                            utxo: @utxo)
      end
    end
  end
end
