# frozen_string_literal: true
module ZenWallet
  module Persistence
    # HD account store
    class Accounts < Store
      def persist(account)
        attrs = { wallet_id: account.wallet.id, id: account.id,
                  order: account.order, address: account.address,
                  private_key: account.private_key,
                  public_key: account.public_key }
        dataset.insert(**attrs) && attrs
      end

      def by_wallet(wallet_id, **filters)
        dataset.where(wallet_id: wallet_id).where(**filters).all
      end

      def lookup(wallet_id, id)
        dataset.where(id: id, wallet_id: wallet_id).first
      end

      def next_index(wallet_id)
        current = dataset.where(wallet_id: wallet_id).max(:order)
        current ? current + 1 : 0
      end

      def set_private_key(wallet_id, id, new_prvate_key)
        acc = dataset.where(wallet_id: wallet_id, id: id).first
        raise "Private key already derived" if acc[:private_key]
        dataset.where(wallet_id: wallet_id, id: id)
               .update(private_key: new_prvate_key)
      end
    end
  end
end
