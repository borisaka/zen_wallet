module ZenWallet
  module HD
    class Store
      class Transactions < StoreBase
        def load(from = 0, to = 20)
          table.get_all([wid, idx], index: "wallet_and_account")
               .order_by(:confirmed, r.desc(:time))
               .limit(to - from)
               .skip(from)
               .run(@conn)
        end

        # TODO: test txs
        def compare_and_save(txs)
          # table.insert(txs, conflict: "replace")
          ids = txs.map(&:txid)
          args = ids.map { |id| [wid, idx, id] }
          stored_txs = table.get_all(*args, index: "watx").run(@conn)
          new_ids = ids - stored_txs.map { |tx| tx["txid"] }
          unless new_ids.empty?
            new_txs = txs.select { |tx| new_ids.include?(tx.txid) }
            table.insert(new_txs.map(&:to_h)).run(@conn)
          end
          new_txs || []
        end

        def update_confirmations(txs)
          r.table("transactions")
           .get_all(*txs.map { |t| t[:txid] }, index: "txid")
           .filter(confirmed: false)
           .update(return_changes: true) \
             { |d| r.expr(txs).filter(txid: d[:txid]).nth(0) }
           .do do |set|
             r.branch(set[:replaced].gt(0),
                      set[:changes].map { |ch| ch[:new_val][:txid] },
                      [])
           end.run(@conn)
        end

        private

        def table
          r.table("transactions")
        end
      end
    end
  end
end
