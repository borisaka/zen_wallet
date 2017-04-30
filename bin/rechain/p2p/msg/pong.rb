module ZenWallet
  module Rechain
    module Msg
      class Pong < AbstractMsg
        def handle(payload)
          nonce = payload.unpack("Q")[0]
          logger.debug("Responded PONG with #{nonce}")
          true
        end

        def generate(nonce)
          logger.debug("Generating PONG with #{nonce}")
          Bitcoin::Protocol.pong_pkt(nonce)
        end
      end
    end
  end
end
