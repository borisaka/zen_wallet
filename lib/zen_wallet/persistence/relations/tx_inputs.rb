module ZenWallet
  module Persistence
    class TxInputs < ROM::Relation[:sql]
      register_as :tx_inputs
      dataset :tx_inputs
      schema(infer: true) do
        associations do
          belongs_to :transaction, foreign_key: :txid
          belongs_to :tx_output, as: :prev_output
        end
      end

      def by_tx(txid)
        where(txid: txid)
      end

      # def by_source(txid, index)
      #
      #  where(source_txid: txid, source_index: index)
      # end
    end
  end
end
