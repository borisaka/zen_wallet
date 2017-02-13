# frozen_string_literal: true
require "btcruby"
require_relative "tx_builder"
require_relative "inputs_helper"
module ZenWallet
  module Bitcoin
    # Helper to make bitcoin transaction
    # only p2ksh for now.
    class TxHelper
      # def change_address()
      # attr_accessor :outputs, inputs
      # Struct working objects
      # @attr address [::BTC::Address]
      NotEnoughMoney = Class.new(StandardError)
      # it only request to spent money
      # @param balance [Insight::Models::Balance]
      #   what stores all account UTXO and some usefull detail
      # @param tx_proposal [TxProposal] simple struct with outputs
      def initialize(tx_proposal, balance)
        @balance = balance
        @tx_proposal = tx_proposal
        @total_amount = @tx_proposal.outputs.map(&:amount).reduce(:+) +
                        @tx_proposal.fees
      end

      # Counts balance, dust amounts, etc...
      def build(&key_provider)
        builder = TxBuilder.new
        raise NotEnoughMoney if @balance.total < @total_amount
        @tx_proposal.outputs.each { |out| builder.output(out) }
        info = InputsHelper
               .prepare_inputs(@balance.utxo, @total_amount, &key_provider)
        change_out = change_output(info.change)
        builder.output(change_out) if change_out
        info.inputs.each { |input| builder.input(input) }
        builder.build
      end

      # optimal find utxo by amount
      # gets private keys on it, find_or_create
      # def sign_inputs
      # end
      def change_output(change)
        if change.positive?
          CommonStructs::AddressAmount.new(
            address: @tx_proposal.change_address,
            amount: change
          )
        end
      end
    end
  end
end
