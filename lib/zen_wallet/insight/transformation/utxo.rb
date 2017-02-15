# frozen_string_literal: true

module ZenWallet
  class Insight
    module Transformation
      UtxoTransform = BaseTransform.define do
        symbolize_keys
        # reject_keys :amount
        rename_keys amount: :mmm
        rename_keys scriptPubKey: :script, satoshis: :amount
        accept_keys %i(address txid vout script confirmations)
        # map_value :amount
      end

      BalanceTransform = BaseTransform.define do
        wrap_all :utxo
        deep_symbolize_keys
        map_value :utxo do
          map_array do
            rename_keys amount: :mmm
            rename_keys scriptPubKey: :script, satoshis: :amount
            accept_keys %i(address txid vout script confirmations amount)
          end
        end
        # t(:map_array, UtxoTransform)
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
