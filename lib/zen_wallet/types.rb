# frozen_string_literal: true
require "dry-types"
module ZenWallet
  # common used types
  # @todo validate bintcoins data. but it must handle current network
  #  and depend on container instance
  module Types
    include Dry::Types.module
    PKey = Strict::String.constrained(max_size: 50)
    HDIndex = Strict::Int.constrained(gteq: 0)
    HDChange = Strict::Int.constrained(included_in: 0..1)
    TxDirection =
      Strict::String.enum("spend", "receive", "inner:account", "inner:wallet")
  end

  # Common structs, used anywhere.
  module CommonStructs
    # Simple pair of bitcoin address and sat amount
    class AddressAmount < Dry::Struct
      attribute :address, Types::Strict::String
      attribute :amount,  Types::Strict::Int
    end

    # UTXO
    class Utxo < AddressAmount
      attribute :txid, Types::Strict::String
      attribute :vout, Types::Strict::Int
      attribute :script, Types::Strict::String
      attribute :confirmations, Types::Strict::Int
    end

    # Prepared and not yet validated proposal.
    class TxProposal < Dry::Struct
      include ZenWallet::CommonStructs
      attribute :outputs, Types::Array.member(AddressAmount)
      attribute :fees, Types::Strict::Int
      attribute :change_address, Types::Strict::String
    end
  end
end
