module ZenWallet
  module Persistence
    class Addresses < ROM::Relation[:sql]
      register_as :addresses
      dataset :addresses
      schema(infer: true) do
        associations do
          belongs_to :account
        end
      end

      def by_account(wallet_id, account_id)
        where(wallet_id: wallet_id, account_id: account_id)
      end

      def with_chain(chain)
        where(chain: chain)
      end
    end
  end
end
