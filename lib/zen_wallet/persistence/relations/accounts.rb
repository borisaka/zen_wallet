module ZenWallet
  module Persistence
    class Accounts < ROM::Relation[:sql]
      register_as :accounts
      dataset :accounts
      schema(infer: true) do
        associations do
          has_many :addresses
        end
      end

      def by_wallet(wallet_id)
        where(wallet_id: wallet_id)
      end
    end
  end
end
