# require "zen_wallet/hd/wallet"
module ZenWallet
  module Persistence
    class Wallets < ROM::Relation[:sql]
      schema(:wallets) do
        attribute :id, Types::Strict::String
        attribute :secured_xprv, Types::Strict::String
        attribute :xpub, Types::Strict::String
        attribute :salt, Types::Strict::String
        primary_key :id
      end

      def lookup(id)
        where(id: id).one
      end

      def exists?(id)
        where(id: id).count.positive?
      end
    end
  end
end
