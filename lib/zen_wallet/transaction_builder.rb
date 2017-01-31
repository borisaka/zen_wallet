# frozen_string_literal: true
require "money-tree"
require "btcruby"
module ZenWallet
  module TransactionBuilder
    extend MoneyTree::Support

    module_function

    def build_transaction(utxo:, outputs:, fee:,
                          private_key_wif:, change_address:)
      sat = outputs.reduce(0) { |acc, elem| acc + elem[:satoshis] } + fee
      utxo = collect_utxo(utxo, sat)
      builder = BTC::TransactionBuilder.new
      builder.input_addresses = [private_key_wif]
      builder.provider = BTC::TransactionBuilder::Provider.new do |txb|
        scripts = txb.public_addresses.map(&:script).uniq
        utxo.find_all { |u| scripts.include?(u.script) }
      end
      builder.outputs = outputs.map do |out|
        BTC::TransactionOutput.new(
          value: out[:satoshis],
          script: BTC::Address.parse(out[:address]).script
        )
      end
      builder.change_address = BTC::Address.parse(change_address)
      # mokey_patch builder
      builder.instance_variable_set("@fee", fee)
      class<<builder
        def compute_fee_for_transaction(*attrs)
          @fee
        end
      end
      # builder
      builder.build.transaction
    end

    def collect_utxo(utxo, sat)
      find_inputs(utxo, sat).map do |i|
        BTC::TransactionOutput
          .new(value:  i[:satoshis],
               script: BTC::PublicKeyAddress.parse(i[:address]).script,
               transaction_id: i[:txid],
               index: i[:vout])
      end
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
