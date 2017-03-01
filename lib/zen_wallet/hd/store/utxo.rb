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
        def update(txs)
          ins = r(txs).concat_map do |tx|
            tx[:account_detail][:outputs]
              .filter { |out| r.not(out.has_fields(:spent_tx_id)) }
              .map { |out| merge_defaults(tx[:txid], out) }
          end
          table.insert(ins).run(@conn)
          # table.get_all([wid, idx], index: "wallet_and_account")
          # txs.outputs
        end

        def find_and_remove_spent
          spent_ids =
            r.table("transactions")
             .get_all([wid, idx], index: "wallet_and_account")
             .coerce_to("array")
             .concat_map { |tx| tx[:account_detail][:inputs] }
             .map { |input| input[:txid] + "." + input[:vout].coerce_to("string") }
          table.get_all(r.args(spent_ids)).delete.run(@conn)
        end

        # def confirm(txids)
        #   table.get_all(txids, index: "txid").update(confirmed: true)
        # end

        # accumulate amount from all UTXO is account balance
        def balance
          table.get_all([wid, idx], index: "wallet_and_account")
               .sum("amount")
               .run(@conn)
        end

        private

        def merge_defaults(txid, out)
          out.merge(id: txid + "." + out[:n].coerce_to("string"),
                    wallet: wid,
                    account: idx,
                    txid: txid)
        end

        def table
          r.table("utxo")
        end
      end
    end
  end
end
