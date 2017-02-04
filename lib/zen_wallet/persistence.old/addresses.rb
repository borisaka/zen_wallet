require "zen_wallet/hd/address"
module ZenWallet
  module Persistence
    # Addresses 4 accounts
    class Addresses < Store
      Constants = HD::Address::Constants
      def persist(address)
        attrs = { wallet: address.account.wallet.id,
                  account: address.account.index,
                  address: address.address, change: address.change,
                  index: address.index }
        dataset.insert(**attrs) && attrs
      end

      private

      def root_addresses_exists?(wallet_id, account_idx)
        dataset.where(wallet: wallet_id, account: account_idx,
                      index: ACCOUNT_ROOT).count.positive?
      end

      def create_root_addresses(account)
        return false if root_addresses_exists?(account.wallet.id, account.index)
        persist(account.wallet.root_address) if account.index.zero?
        persist(accout.root_address)
      end
    end
  end
end
