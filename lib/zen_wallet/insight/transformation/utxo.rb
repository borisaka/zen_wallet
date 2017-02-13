module ZenWallet
  class Insight
    module Transformation
      UtxoTransform = BaseTransform.define do
        symbolize_keys
        rename_keys scriptPubKey: :script, satoshis: :amount
        accept_keys %i(address amount txid vout script confirmations)
      end

      BalanceTransform = BaseTransform.define do
        deep_symbolize_keys
        map_value :utxo, t(:map_array, UtxoTransform)
        copy_keys utxo: :total
        map_value :total do
          sum :amount
        end
        copy_keys utxo: :addresses
        map_value :addresses do
          map_array t(:accept_keys, %i(address amount))
          sum :amount, %i(address)
        end
        constructor_inject Models::Balance
      end
    end
  end
end
