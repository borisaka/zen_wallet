# frozen_string_literal: true
module ZenWallet
  module Rechain
    module Msg
      # Alert from peers
      class Alert < AbstractMsg
        def handle(payload)
          alert = Bitcoin::Protocol::Alert.parse(payload)
          logger.warn("Alert with: #{alert.to_h}")
          alert
        end

        # def generate
        #   Bitcoin::Protocol.ping_pkt
        # end
      end
    end
  end
end
