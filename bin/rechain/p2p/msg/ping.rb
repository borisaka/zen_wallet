# frozen_string_literal: true
module ZenWallet
  module Rechain
    module Msg
      # Ping mesage
      class Ping < AbstractMsg
        def handle(payload)
          nonce = payload.unpack("Q")[0]
          logger.debug("handled ping with #{nonce}")
          @connection.gen_and_send_msg(:pong, nonce)
          true
        end

        def generate
          Bitcoin::Protocol.ping_pkt
        end
      end
    end
  end
end
