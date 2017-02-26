require "rom-repository"
require "zen_wallet/hd/models"

module ZenWallet
  module Persistence
    # Repo to store addresses
    # Help to keep gap limit
    class AddressRepo < ROM::Repository[:addresses]
      commands :create
      Model = HD::Models::Address
      def find(addrs)
        query = root.by_pk(addrs).as(Model)
        addrs.is_a?(Array) ? query.to_a : query.one
      end

      def count(wallet_id, account_index, chain, **filters)
        root.by_account(wallet_id, account_index)
            .with_chain(chain)
            .where(filters).count
      end

      def last_idx(wallet_id, account_index, chain)
        root.select(:index).by_account(wallet_id, account_index)
            .with_chain(chain)
            .order(:index)
            .pluck(:index).last
      end
      #
      # def first_by(wallet_id, account_index, chain, **filters)
      #   root.by_account(wallet_id, account_index)
      #       .with_chain(chain)
      #       .where(filters)
      #       .order(:index).as(Model).first
      # end

      def pluck_address(wallet_id, account_index, offset, **filters)
        query = root.select(:address).by_account(wallet_id, account_index)
                    .order(:index).reverse
                    .offset(offset)
        query = query.where(filters) if filters
        query.pluck(:address)
      end

      def free_address(wallet_id, account_index, chain)
        query = root.select(:address).by_account(wallet_id, account_index)
                    .order(:index).reverse
                    .where(chain: chain, has_txs: false)
                    .limit(1)
        query.pluck(:address)[0]
      end

      def update_addresses(addresses, new_attrs)
        root.by_pk(addresses).update(new_attrs)
      end
    end
  end
end
