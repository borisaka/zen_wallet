module ZenWallet
  module Persistence
    module TxAccountMixin
      def tx_account_amount(txid, wallet_id, account_id)
        root.where(txid: txid, wallet_id: wallet_id, account_id: account_id)
            .select { int::sum(amount).as(:amount) }
            .one!.amount || 0
      end
    end
  end
end
