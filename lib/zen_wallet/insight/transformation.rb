# frozen_string_literal: true
require "json"
require "transproc/all"
require_relative "models"
module ZenWallet
  class Insight
    # Module to transform bitcore insight api result to strict structures
    # @api private
    module Transformation
      # @api private
      module Registry
        extend Transproc::Registry
        import Transproc::HashTransformations
        import Transproc::ArrayTransformations
        import Transproc::Coercions
        import Transproc::ClassTransformations

        def self.aggregate(ary, key = nil, groupings = [], reduce: nil)
          # to be...
          group_keys = [*groupings]
          # grouping by key array key
          group_fun = lambda do |hsh|
            group_keys.map { |gkey| [gkey, hsh[gkey]] }
          end
          # Just takes value from hash or even it value
          map_fn = ->(hsh) { hsh[key] }
          # destroy hash. now appear [key, (sum this key on hash)]
          sum_fn = ->(hashes) { [key, hashes.map(&map_fn).reduce(&reduce)] }
          ungroup_fn = ->(header, values) { Hash[[*header, sum_fn[values]]] }
          # Now wee need to know what exactly needed
          if groupings.size.positive?
            groups = ary.group_by(&group_fun)
            groups.map(&ungroup_fn)
          elsif ary.all? { |el| el.is_a?(Hash) } && key
            sum_fn[ary].last
          else
            ary.reduce(&reduce)
          end
        end

        def self.sum(ary, key = nil, groupings = [])
          aggregate(ary, key, groupings, reduce: :+)
        end

        def self.btc_to_sat(btc)
          Integer(btc.to_f * 1e8)
        end

        def self.time_at(num)
          num ? Time.at(num) : nil
        end

        def self.join_addr(addresses)
          addresses.join(",")
        end
      end

      BaseTransform = Class.new(Transproc::Transformer[Registry])



      TxInTransform = BaseTransform.define do
        symbolize_keys
        rename_keys valueSat: :amount, addr: :address
        reject_keys %i(scriptSig doubleSpentTxID value sequence)
        constructor_inject(Models::TxIn)
      end

      TxOutTransform = BaseTransform.define do
        deep_symbolize_keys
        unwrap :scriptPubKey, %i(hex addresses type)
        rename_keys value: :amount, addresses: :address, hex: :script
        # money
        map_value :amount, t(:btc_to_sat)
        # addresses
        map_value :address, ->(addr) { addr.join(",") }
        accept_keys %i(n amount address script type)
        constructor_inject(Models::TxOut)
      end

      TxTransform = BaseTransform.define do
        deep_symbolize_keys
        rename_keys vin: :inputs, vout: :outputs, valueIn: :amount_in,
                    valueOut: :amount_out
        map_value :amount_in, t(:btc_to_sat)
        map_value :amount_out, t(:btc_to_sat)
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
      require_relative "transformation/utxo"
    end
  end
end
