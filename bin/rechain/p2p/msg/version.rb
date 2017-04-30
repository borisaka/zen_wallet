# frozen_string_literal: true
module ZenWallet
  module Rechain
    module Msg
      # Version message
      # @see https://bitcoin.org/en/developer-reference#version
      class Version < AbstractMsg
        def generate
          Bitcoin::Protocol::Version.new(
            user_agent: "ruby-eventmachine/zenwallet-server",
            last_block: 0,
            services: 0,
            from: "127.0.0.1:#{@connection.network.default_port}",
            to: "#{@connection.host}:#{@connection.port}"
          ).to_pkt
        end

        def handle(payload)
          version = Bitcoin::Protocol::Version.new.parse(payload)
          logger.info("Peer version: #{version.fields}")
          logger.info("Sending verack")
          @connection.gen_and_send_msg(:verack)
          version
        end
      end
    end
  end
end
