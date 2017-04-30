module ZenWallet
  module Persistence
    class TxOutputs < ROM::Relation[:sql]
      register_as :tx_outputs
      dataset :tx_outputs
      schema(infer: true) do
        associations do
          belongs_to :transaction, foreign_key: :txid
        end
      end

      def by_tx(txid)
        where(txid: txid)
      end

     #def by_spent(txid, index)
     #  where(spent_txid: txid, spent_index: index)
     #end

      def by_address(address)
        where(address: address)
      end
    end
  end
end
