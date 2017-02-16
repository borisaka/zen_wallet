require "rom-repository"
require "zen_wallet/hd/models"

module ZenWallet
  module Persistence
    # Repo to store addresses
    # Help to keep gap limit
    class AddressRepo < ROM::Repository[:addresses]
      commands :create, update: :by_pk
      Model = HD::Models::Address
      # Indepodent loads address model
      # # @return [HD::Models::Address]
      # def find_or_create(model)
      #   if root.by_pk(model.address).count.positive?
      #     root.by_pk(model.address).as(Model).first
      #   else
      #     root.insert(model.to_h)
      #   end
      #   model
      # end

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
        root.by_account(wallet_id, account_index)
            .with_chain(chain)
            .order(:index)
            .pluck(:index).last
      end

      def first_by(wallet_id, account_index, chain, **filters)
        root.by_account(wallet_id, account_index)
            .with_chain(chain)
            .where(filters)
            .order(:index).as(Model).first
      end

      def pluck_address(wallet_id, account_index, offset, **filters)
        query = root.select(:address).by_account(wallet_id, account_index)
                    .order(:index).reverse
                    .offset(offset)
        query = query.where(filters) if filters
        query.pluck(:address)
      end

      # Sets 'requested' flag to address, to prevent double sugguesting
      # # @return [HD::Models::Address] with updated property
      # def mark_as_requested(model)
      #   root.by_pk(model.address).update(requested: true)
      #   Model.new(model.to_h.merge(requested: true))
      # end
      #
      # # Sets 'used' flag to address, to reduce known gap limit usage
      # # @return [HD::Models::Address] with updated property
      # def mark_as_used(model)
      #   root.by_pk(model.address).update(has_txs: true)
      #   Model.new(model.to_h.merge(has_txs: true))
      # end

      # Select all adresses with single address field
      # @return Array[String]


      # Sugguest new address
      # def next_recv(wallet_id, account_index, ignore_requested)
      #   query = root.by_account(wallet_id, account_index).unused.receivers
      #   query.not_been_requested if ignore_requested
      #   query.order(:index).as(Model).first
      # end
      #
      # # Unused external address count
      # def gap_size(wallet_id, account_index)
      #   root.by_account(wallet_id, account_index).unused.receivers.count
      # end
      #
      # # Free index
      # def next_index(wallet_id, account_index)
      #   root.by_account(wallet_id, account_index).max(:index)&.+(1) || 0
      # end


    end
  end
end
