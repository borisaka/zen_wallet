module ZenWallet
  module Persistence
    class TxHistoryRepo < ROM::Repository[:tx_history]
      commands :create
      relations :transactions, :tx_outputs

      def detect(txid, wallet_id, account_id)
        root.where(txid: txid, wallet_id: wallet_id, account_id: account_id).one
      end

      def account_balance(wallet_id, account_id)
        root.account_balance(wallet_id, account_id).one&.balance || 0
      end

      def account_history(wallet_id, account_id)
        root.account_history(wallet_id, account_id).as(:history_item).to_a
      end
    end
  end
end
