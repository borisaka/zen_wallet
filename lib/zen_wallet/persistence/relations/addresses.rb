require "zen_wallet/hd/address"
module ZenWallet
  module Persistence
    class Addresses < ROM::Relation[:sql]
      register_as :addresses
      dataset :addresses
      schema(infer: true)

      def by_account(wallet_id, account_index)
        where(wallet_id: wallet_id, account_index: account_index)
      end

      def by_change(change)
        where(change: change)
      end

      def not_been_requested
        where(requested: false)
      end

      def unused
        where(has_txs: false)
      end

      def receivers
        by_change(0)
      end

      def senders
        by_change(1)
      end
    end
  end
end
