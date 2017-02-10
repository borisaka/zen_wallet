# frozen_string_literal: true
require "json"
require "transproc/all"
require_relative "models"
module ZenWallet
  class Insight
    module Transformation
      module Registry
        extend Transproc::Registry
        import Transproc::HashTransformations
        import Transproc::ArrayTransformations
        import Transproc::Coercions
        import Transproc::ClassTransformations

        def self.btc_to_sat(btc)
          Integer(btc.to_f * 1e8)
        end

        def self.time_at(num)
          Time.at(num)
        end

        def self.join_addr(addresses)
          addresses.join(",")
        end
      end

      BaseTransform = Class.new(Transproc::Transformer[Registry])

      UtxoTransform = BaseTransform.define do
        map_array do
          symbolize_keys
          rename_keys scriptPubKey: :script
          accept_keys %i(address txid vout script satoshis)
          constructor_inject(Models::Utxo)
        end
      end

      TxInTransform = BaseTransform.define do
        symbolize_keys
        rename_keys valueSat: :satoshis, addr: :address
        reject_keys %i(scriptSig doubleSpentTxID value sequence)
        constructor_inject(Models::TxIn)
      end

      TxOutTransform = BaseTransform.define do
        deep_symbolize_keys
        unwrap :scriptPubKey, %i(hex addresses type)
        rename_keys value: :satoshis, addresses: :address, hex: :script
        # money
        map_value :satoshis, t(:btc_to_sat)
        # addresses
        map_value :address, ->(addr) { addr.join(",") }
        accept_keys %i(n satoshis address script type)
        constructor_inject(Models::TxOut)
      end

      TxTransform = BaseTransform.define do
        deep_symbolize_keys
        rename_keys vin: :inputs, vout: :outputs, valueIn: :satoshis_in,
                    valueOut: :satoshis_out
        map_value :satoshis_in, t(:btc_to_sat)
        map_value :satoshis_out, t(:btc_to_sat)
        map_value :fees, t(:btc_to_sat)
        map_value :time, t(:time_at)
        map_value :blocktime, t(:time_at)
        map_value :inputs, t(:map_array, TxInTransform)
        map_value :outputs, t(:map_array, TxOutTransform)
        reject_keys %i(version locktime blockhash blockheight size)
        constructor_inject(Models::Tx)
      end

      TxPageTransform = BaseTransform.define do
        symbolize_keys
        rename_keys totalItems: :total, items: :txs
        map_value :txs, t(:map_array, TxTransform)
        constructor_inject(Models::TxPage)
      end
    end
  end
end
