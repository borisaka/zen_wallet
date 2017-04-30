require "zen_wallet/persistence/tx_account_mixin"
module ZenWallet
  module Persistence
    class TxInputRepo < ROM::Repository[:tx_inputs]
      include TxAccountMixin
      commands :create

      def by_tx(txid)
        root.by_tx(txid).to_a
      end

      # By output where received coins
      #def by_source(txid, index)
      #  root.by_source(txid, index).one
      #end
    end
  end
end
