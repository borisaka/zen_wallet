require "zen_wallet/types"
module ZenWallet
  module Bitcoin
    class PrivateKey
      def self.provide(value)
        raise "Must be BTC::Key instance" unless value.is_a?(BTC::Key)
        raise "KEY MUST BE PRIVATE, NOT PUBLIC" if value.private_key.nil?
      end
    end


    module Types
      Dry::Types.register_class(PrivateKey, :provide)
      include Dry::Types.module
      BTC = ZenWallet::Bitcoin
      # include ZenWallet::Types
    end

    # class UnlockedAddress <
      # attribute :address, Types::Strict::String
      # attribute :key_wif, Types::Strict::String
    # end

    class PreparedInput < CommonStructs::Utxo
      attribute :key_wif, Types::Strict::String
    end
    # Extended UTXO with address private key
    # Collection of inputs with metadata
    class PreparedInputCollection < Dry::Struct
      attribute :inputs, Types::Array.member(PreparedInput)
      attribute :required_amount, Types::Strict::Int
      attribute :inputs_amount, Types::Strict::Int
      attribute :change, Types::Strict::Int
    end
  end
end
