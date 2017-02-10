# frozen_string_literal: true
require "rom-repository"
require "zen_wallet/models"

module ZenWallet
  module Persistence
    class AccountRepo < ROM::Repository[:accounts]
      # commands :create

      def find(wallet_id, id)
        root.by_pk(wallet_id, id).as(Models::Account).first
      end

      def next_index(wallet_id, id)
        root.by_pk(wallet_id, id).pluck(:index).first || \
          root.by_wallet(wallet_id).max(:index)&.+(1) || 0
      end

      def persist(model)
        if root.by_pk(model.wallet_id, model.id).count.positive?
          root.by_pk(model.wallet_id, model.id).update(xprv: model.xprv)
        else
          root.insert(model.to_h)
        end
        model
      end

      # def update_xprv(wallet_id, id, xprv)
      #   # cs = changeset()
      #   root.by_pk(wallet_id, id).update(xprv: xprv)
      # end
    end
  end
end
