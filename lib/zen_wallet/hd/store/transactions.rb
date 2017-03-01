module ZenWallet
  module HD
    class Store
      class Transactions < StoreBase
        def load(from = 0, to = 20)
          table.get_all([wid, idx], index: "wallet_and_account")
               .order_by(:confirmed, r.desc(:time))
               .limit(to - from)
               .skip(from)
               .map { |tx| tx.without(:id, :confirmations) }
               .run(@conn).to_a
        end

        # TODO: test txs
        def compare_and_save(txs)
          txs = txs.map(&:to_h)
                   .map { |tx| tx.merge(id: "#{wid}.#{idx}.#{tx[:txid]}") }
          update = r.table("transactions")
                    .insert(txs, conflict: "update", return_changes: true)
          update[:changes].filter { |ch| r.not(ch.has_fields(:old_val)) }
                          .with_fields(:new_val)
                          .map { |ch| ch[:new_val] }
                          .run(@conn)
        end

        # def exists?(txs)
        #   ids = txs.map(&:to_h, )
        # end

        # def update_confirmations(txs)
        #   r.table("transactions")
        #    .get_all(*txs.map { |t| t[:txid] }, index: "txid")
        #    .filter(confirmed: false)
        #    .update(return_changes: true) \
        #      { |d| r.expr(txs).filter(txid: d[:txid]).nth(0) }
        #    .do do |set|
        #      r.branch(set[:replaced].gt(0),
        #               set[:changes].map { |ch| ch[:new_val][:txid] },
        #               [])
        #    end.run(@conn)
        # end

        private

        def table
          r.table("transactions")
        end
      end
    end
  end
end
