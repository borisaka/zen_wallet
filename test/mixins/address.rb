# frozen_string_literal: true
require_relative "account"
module ZenWallet
  module AddressMixin
    include AccountMixin

    private

    def gen_address(acc_model, chain, index)
      keychain = account_keychain(acc_model)
      raise "NOT VALID CHAIN" unless [0, 1].include? chain
      keychain
        .derived_keychain(chain, hardened: false)
        .derived_key(index).address.to_s
    end

    def address_attrs(acc_model, chain, index,
                      has_txs: false,
                      requested: false)
      addr = gen_address(acc_model, chain, index)
      {
        address: addr,
        wallet_id: acc_model.wallet_id,
        account_index: acc_model.index,
        chain: chain,
        index: index,
        has_txs: has_txs,
        requested: requested
      }
    end

    def address_model(acc_model, chain, index,
                      has_txs: false,
                      requested: false)

      attrs = address_attrs(acc_model, chain, index,
                            has_txs: has_txs,
                            requested: requested)

      ZenWallet::HD::Models::Address.new(attrs)
    end
  end
end
