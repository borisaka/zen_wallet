module ZenWallet
  module Persistence
    class Addresses < ROM::Relation[:sql]
      register_as :addresses
      dataset :addresses
      schema(infer: true)

      def by_account(wallet_id, account_index)
        where(wallet_id: wallet_id, account_index: account_index)
      end

      def with_chain(chain)
        where(chain: chain)
      end
    end
  end
end
