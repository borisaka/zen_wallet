# frozen_string_literal: true
require "rom-repository"
require "zen_wallet/hd/models"

module ZenWallet
  module Persistence
    class WalletRepo < ROM::Repository[:wallets]
      Model = HD::Models::Wallet
      class UnpermittedUpdate < StandardError
        def message
          "Ony 'secured_xprv' and 'salt' togever allowed to update"
        end
      end
      commands :create

      def find(id)
        root.by_pk(id).as(Model).first
      end

      def update_passphrase(model)
        id = model.id
        cs = changeset(id, model.to_h)
        validate_changeset(cs)
        root.by_pk(id).update(cs.diff)
        true
      end

      private

      def validate_changeset(cs)
        raise UnpermittedUpdate unless cs.diff.keys == %i(secured_xprv salt)
      end
    end
  end
end
