module ZenWallet
  class Insight
    # Structures for bitcore insight api result
    module Models
      extend ZenWallet::CommonStructs
      # Aggregated account balance
      class Balance < Dry::Struct
        include ZenWallet::CommonStructs
        attribute :total, Types::Strict::Int
        attribute :addresses, Types::Strict::Array.member(AddressAmount)
        attribute :utxo, Types::Strict::Array.member(Utxo)
      end
    end
  end
end
