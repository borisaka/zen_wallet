module ZenWallet
  module Persistence
    # Bip44 m / purpose' / coin_type' / account' / change / address_index
    class ChainAddresses < Store
      # @param ca [ChainAddress] bitcoin address from account
      def persist(ca)
        attrs = { address: ca.address, account_id: ca.account.id,
                  wallet_id: ca.account.wallet.id,
                  change: ca.change, order: ca.order,
                  public_key: ca.public_key, private_key: ca.private_key }
        dataset.insert(**attrs) && attrs
      end

      def lookup(wallet_id, account_id, change, order)
        dataset.where(wallet_id: wallet_id, account_id: account_id,
                      change: change, order: order).first
      end

      def next_index(wallet_id, account_id)
        current = dataset
                  .where(wallet_id: wallet_id, account_id: account_id)
                  .max(:order)
        current ? current + 1 : 0
      end
    end
  end
end
