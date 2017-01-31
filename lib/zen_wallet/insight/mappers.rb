require 'transproc/all'
require_relative "models"
module ZenWallet
  module Insight
    module Mappers
      module T
        extend Transproc::Registry
        import Transproc::ArrayTransformations
        import Transproc::HashTransformations
        def self.btc_to_sat(btc)
          Integer(btc.to_f * 1e8)
        end

        def self.epoch_to_dt(epoch)
          Time.at(epoch).to_datetime if epoch
        end
      end

      class TxOutMapper < Transproc::Transformer
        map_array do
          deep_symbolize_keys
          map_value :value, T[:btc_to_sat]
          unwrap :scriptPubKey
          map_value :addresses, ->(arr) { arr.first }
          rename_keys value: :satoshis, addresses: :address
          constructor_inject Models::TxOut
        end
      end

      class TxInMapper < Transproc::Transformer
        map_array do
          symbolize_keys
          map_value :value, T[:btc_to_sat]
          rename_keys value: :satoshis, addr: :address
          constructor_inject Models::TxIn
        end
      end

      class TxMapper < Transproc::Transformer
        map_array do
          symbolize_keys
          map_value :time, T[:epoch_to_dt]
          map_value :blocktime, T[:epoch_to_dt]
          map_value :valueIn, T[:btc_to_sat]
          map_value :valueOut, T[:btc_to_sat]
          map_value :fees, T[:btc_to_sat]
          map_value :vin, ->(inputs) { TxInMapper.new.call(inputs) }
          map_value :vout, ->(outputs) { TxOutMapper.new.call(outputs) }
          rename_keys valueIn: :input_sat, valueOut: :output_sat,
                      vin: :inputs, vout: :outputs
          constructor_inject Models::Tx
        end
      end
    end
  end
end
