module ZenWallet
  module Persistence
    class Wallets < ROM::Relation[:sql]
      register_as :wallets
      dataset :wallets
      schema(infer: true)

      # def lookup(id)
      #   where(id: id).one
      # end
      #
      # def exists?(id)
      #   where(id: id).count.positive?
      # end
    end
  end
end
