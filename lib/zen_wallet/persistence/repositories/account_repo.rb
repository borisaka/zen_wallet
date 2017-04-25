# frozen_string_literal: true
require "rom-repository"
require "zen_wallet/hd/models"

module ZenWallet
  module Persistence
    # Repo for account
    class AccountRepo < ROM::Repository[:accounts]

      def to_update
        root.to_a
      end

      # Find by pair wallet_id, id
      # @return [HD::Models::Account]
      # @return nil
      def find(wallet_id, id)
        root.by_pk(wallet_id, id).as(HD::Models::Account).first
      end

      # free BIP44 account index
      # @return [Integer]
      def next_index(wallet_id, id)
        root.by_pk(wallet_id, id).pluck(:index).first || \
          root.by_wallet(wallet_id).max(:index)&.+(1) || 0
      end

      # Creates wallet, or updates xprv column
      # @return [HD::Models::Account] with applyed changes if any
      def persist(model)
        if root.by_pk(model.wallet_id, model.id).count.positive?
          root.by_pk(model.wallet_id, model.id).update(xprv: model.xprv)
        else
          root.insert(model.to_h)
        end
        model
      end
    end
  end
end
