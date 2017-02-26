# frozen_string_literal: true
require "btcruby"
require_relative "tx_builder"
require_relative "inputs_helper"
module ZenWallet
  module Bitcoin
    # Helper to make bitcoin transaction
    # only p2ksh for now.
    class TxHelper
      NotEnoughMoney = Class.new(StandardError)
      # BuildedTx = Struct.new(:txid, :inputs, :outputs)
      # it only request to spent money
      # @param tx_proposal [TxProposal] simple struct with outputs
      # @param utxo [Array<Insight::Models::Utxo>]
      # @param balance [Integer] balance
      def initialize(tx_proposal, balance, utxo)
        @tx_proposal = tx_proposal
        @balance = balance
        @utxo = utxo
        @total_amount = @tx_proposal.outputs.map(&:amount).reduce(:+) +
                        @tx_proposal.fees
      end

      # Counts balance, dust amounts, etc...
      def build(&key_provider)
        builder = TxBuilder.new
        raise NotEnoughMoney if @balance < @total_amount
        @tx_proposal.outputs.each { |out| builder.output(out) }
        info = InputsHelper.prepare_inputs(@utxo, @total_amount, &key_provider)
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
