module ZenWallet
  module HD
    class Store
      class Utxo < StoreBase
        # Load account UTXO
        def load
          table.get_all([wid, idx], index: "wallet_and_account").run(@conn).to_a
        end

        # Updates UTXO from new transactions
        #   delete utxo what spent
        #   insert new from outputs assigned to account addresses
        def update_from_txs(txs)
          to_insert = txs.map do |tx|
            tx.account_detail.outputs
              .map(&:to_h)
              .map do |h|
                h.merge(txid: tx.txid,
                        wallet: wid,
                        account: idx,
                        confirmations: tx.confirmations,
                        confirmed: tx.confirmed)
              end
          end.flatten
          to_delete = txs.map { |tx| tx.account_detail.inputs }.flatten
          table.insert(to_insert).run(@conn)
          delete_ids = to_delete.map do |input|
            [input.txid, input.vout]
          end
          table.get_all(*delete_ids, index: "txid_and_n").delete.run(@conn)
        end

        def confirm(txids)
          table.get_all(txids, index: "txid").update(confirmed: true)
        end

        # accumulate amount from all UTXO is account balance
        def balance
          table.get_all([wid, idx], index: "wallet_and_account")
               .sum("amount")
               .run(@conn)
        end

        private

        def table
          r.table("utxo")
        end
      end
    end
  end
end
