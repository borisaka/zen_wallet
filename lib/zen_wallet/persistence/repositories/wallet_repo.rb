# frozen_string_literal: true
require "rom-repository"
require "zen_wallet/hd"

module ZenWallet
  module Persistence
    class WalletRepo < ROM::Repository[:wallets]
      commands :create, update: :by_pk
      Model = HD::Wallet::Model

      def [](id)
        attrs = wallets.lookup(id)
        Model.new(attrs) if attrs
      end

      def exists?(id)
        wallets.where(id: id).count.positive?
      end

      def change(id, **attrs)
        Model.new(update(id, changeset(id, attrs)).to_h)
      end
    end
  end
end
