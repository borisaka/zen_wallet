module ZenWallet
  class Insight
    # Structures for bitcore insight api result
    module Models
      extend ZenWallet::CommonStructs
      # Aggregated account balance
      class Balance < Dry::Struct
        constructor_type  :permissive
        include ZenWallet::CommonStructs
        attribute :total, Types::Strict::Int.default(0)
        attribute :addresses, Types::Strict::Array
                              .member(AddressAmount).default([])
        attribute :utxo, Types::Strict::Array.member(Utxo).default([])
      end
    end
  end
end
