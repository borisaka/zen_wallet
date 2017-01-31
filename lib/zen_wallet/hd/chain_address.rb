# frozen_string_literal: true
module ZenWallet
  module HD
    # Chain address to receive and spent money
    class ChainAddress
      # 0 - for receiving money (address seen from outside)
      # 1 - for sendiing money (p2sh I suppose)
      # @todo P2SH
      CHANGE_TYPES = %i(external internal).freeze
      extend Dry::Initializer::Mixin
      include Dry::Equalizer(:address)
      param :account
      option :address
      option :change
      option :order
      option :private_key
      option :public_key

      def to_path
        "m/#{account.order}/#{change}/#{order}"
      end

      # Receiving payment
      def external?
        CHANGE_TYPES[change] == :external
      end

      # Sending payment
      def internal?
        CHANGE_TYPES[change] == :internal
      end
    end
  end
end
