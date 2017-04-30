module ZenWallet
  module Rechain
    class Network < BTC::Network
      attr_accessor :magic
      attr_accessor :default_port

      def self.mainnet
        @mainnet ||= begin
          network = super
          network.default_port = 8333
          network.magic = "\xF9\xBE\xB4\xD9"
          network
        end
      end

      def self.testnet
        @testnet ||= begin
          network = super
          network.default_port = 18333
          network.magic = "\v\x11\t\a"
          network
        end
      end

    end
  end
end
