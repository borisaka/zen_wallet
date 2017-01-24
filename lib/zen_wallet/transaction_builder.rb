# frozen_string_literal: true
require "bitcoin"
require_relative "browser"
require "money-tree"
require "btcruby"
module ZenWallet
  module TransactionBuilder
    extend Bitcoin::Builder
    extend MoneyTree::Support

    module_function

    def build_transaction(utxo:, outputs:, fee:,
                          private_key_wif:, change_address:)
      sat = outputs.reduce(0) { |acc, elem| acc + elem[:satoshis] } + fee
      inputs = find_inputs(utxo, sat)
      utxo = inputs.map do |i|
        BTC::TransactionOutput
          .new(value:  i[:satoshis],
               script: BTC::PublicKeyAddress.parse(i[:address]).script,
               transaction_id: i[:txid],
               index: i[:vout])
      end
      builder = BTC::TransactionBuilder.new
      builder.input_addresses = [private_key_wif]
      builder.provider = BTC::TransactionBuilder::Provider.new do |txb|
        # utxo
        # puts "TXB: #{txb.public_addresses}"
        scripts = txb.public_addresses.map{ |a| a.script }.uniq
        # puts "SCRIPTS: #{scripts}"
        # puts "UTXO: #{utxo}"
        utxo.find_all { |u| scripts.include?(u.script) }
      end
      # builder.unspent_outputs_provider_block = lambda do |addresses, outputs_amount, outputs_size, fee_rate|
      #   inputs.map do |input|
      #     BTC::TransactionOutput.new(
      #       value: input[:satoshis],
      #       script: BTC::PublicKeyAddress.parse(input[:address]).script,
      #       transaction_id: input[:tx_id],
      #       index: 0
      #    )
      #   end
      # end
      builder.outputs = outputs.map do |out|
        BTC::TransactionOutput.new(
          value: out[:satoshis],
          script: BTC::Address.parse(out[:address]).script
        )
      end
      builder.change_address = BTC::Address.parse(change_address)
      builder.build
    end

    def find_inputs(utxo, sat)
      enough = lambda do |inputs, amount|
        inputs.reduce(0) { |acc, elem| acc + elem[:satoshis] } >= amount
      end
      raise "Amount too big" unless enough.call(utxo, sat)
      sort = ->(x, y) { x[:satoshis] <=> y[:satoshis] }
      small, big = utxo.sort(&sort)
                       .partition { |u| u[:satoshis] < sat }
      enough.call(small, sat) ? collect_small(small, sat) : [big.first]
    end

    def collect_small(utxo, sat)
      head, *tail = utxo
      current = head[:satoshis]
      current >= sat ? [head] : [head, *collect_small(tail, sat - current)]
    end
  end
end
