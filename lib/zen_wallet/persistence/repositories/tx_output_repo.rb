require "zen_wallet/persistence/tx_account_mixin"
module ZenWallet
  module Persistence
    class TxOutputRepo < ROM::Repository[:tx_outputs]
      include TxAccountMixin
      commands :create
      relations :tx_inputs

      def detect(txid, index)
        root.by_pk(txid, index).one
      end

      def by_tx(txid)
        root.by_tx(txid).to_a 
      end

      def by_address(address)
        root.by_address(address).to_a
      end

      def utxo(wallet_id, account_id)
        root
          .select(*root.schema.qualified)
          .left_join(:tx_inputs, prev_txid: :txid, prev_index: :index)
          .where(root[:wallet_id].qualified => wallet_id,
                 root[:account_id].qualified => account_id,
                 prev_index: nil)
          .to_a
      end

    end
  end
end
