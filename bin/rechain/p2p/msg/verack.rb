# frozen_string_literal: true
module ZenWallet
  module Rechain
    module Msg
      # Verack message: sends to peer then version received
      # @see https://bitcoin.org/en/developer-reference#verack
      class Verack < AbstractMsg
        def handle(_)
          logger.info("handled verack!")
        end

        def generate
          Bitcoin::Protocol.verack_pkt
        end
      end
    end
  end
end
