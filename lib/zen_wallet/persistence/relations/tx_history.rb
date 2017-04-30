module ZenWallet
  module Persistence
    class TxHistory < ROM::Relation[:sql]
      register_as :tx_history
      dataset :tx_history
      schema(infer: true) do
        associations do
          belongs_to :transaction, foreign_key: :txid
        end
      end

      def desc_order
        join(:transactions, txid: :txid).order(Sequel.lit("block_height desc, block_position desc"))
      end

      def by_account(wallet_id, account_id)
        where(wallet_id: wallet_id, account_id: account_id)
      end

      def account_balance(wallet_id, account_id)
        by_account(wallet_id, account_id).desc_order.limit(1).select(:balance)
      end

      def account_history(wallet, account)
        desc_order
          .order(Sequel.desc(:tx_outputs__amount))
          .join(:tx_outputs, txid: :txid)
          .where(tx_history__wallet_id: wallet, tx_history__account_id: account)
          .select { [amount.qualified, balance, txid.qualified, 
                     wallet_id.qualify(:tx_outputs), account_id.qualify(:tx_outputs),
                     amount.qualify(:tx_outputs).as(:out_amount)] }
          .limit(20)
          #.select_append(Sequel.lit("transactions.*"), Sequel.lit("tx_outputs.*"))
      end
    end
  end
end
