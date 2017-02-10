require "rom-repository"
require "zen_wallet/models"

module ZenWallet
  module Persistence
    class AddressRepo < ROM::Repository[:addresses]

      def find_or_create(model)
        if root.by_pk(model.address).count.positive?
          root.by_pk(model.address).as(Models::Address).first
        else
          root.insert(model.to_h)
        end
        model
      end

      def mark_as_requested(model)
        root.by_pk(model.address).update(requested: true)
        Models::Address.new(model.to_h.merge(requested: true))
      end

      def mark_as_used(model)
        root.by_pk(model.address).update(has_txs: true)
        Models::Address.new(model.to_h.merge(has_txs: true))
      end

      def pluck_address(wallet_id, account_index)
        root.by_account(wallet_id, account_index).receivers.pluck(:address)
      end

      def next_unused_recv(wallet_id, account_index)
        root.by_account(wallet_id, account_index)
            .unused.not_been_requested.receivers.order(:index)
            .as(Models::Address).first
      end

      # Unused external address count
      def gap_size(wallet_id, account_index)
        root.by_account(wallet_id, account_index).unused.receivers.count
      end

      # Unused external address from last index
      def unused_recvs(wallet_id, account_index)
        root.by_account(wallet_id, account_index)
            .unused
            .receivers
            .as(Models::Address).to_a
      end

      def next_index(wallet_id, account_index)
        root.by_account(wallet_id, account_index).max(:index)&.+(1) || 0
      end
    end
  end
end
