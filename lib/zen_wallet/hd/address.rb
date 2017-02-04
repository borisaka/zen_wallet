# frozen_string_literal: true
require "dry-initializer"
module ZenWallet
  module HD
    class Address
      # BIP44 Change field (4'th value in path)
      module Constants
        RECV_CHANGE = 0
        SND_CHANGE = 1
        # For root wallet and account address.. Wallet should not use it
        # But if it has transactions we must detect it for safe user money
        BOTH_CHANGE = -1
        CHANGES_ALLOWED = [BOTH_CHANGE, RECV_CHANGE, SND_CHANGE].freeze
        MAX_IDX = 2 * 2**31
        # Fake index for root address.
        WALLET_IDX = -2
        ACCOUNT_IDX = -1
      end

      extend Dry::Initializer::Mixin
      param :account
      option :address, Dry::Types["strict.string"]
      option :change, Dry::Types["strict.int"]
        .constrained(included_in: Constants::CHANGES_ALLOWED)
      option :index, Dry::Types["strict.int"]
        .constrained(gteq: Constants::WALLET_IDX, lteq: Constants::MAX_IDX)

      def path
        case index
        when WALLET_IDX then accout.wallet.path
        when ACCOUNT_IDX then account.path
        else "#{account.path}/#{change}/#{index}"
      end
    end
  end
end
