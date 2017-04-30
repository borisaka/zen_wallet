# frozen_string_literal: true
require "dry-monads"
module ZenWallet
  module Rechain
    # Parse bitcoin message
    module MsgParser
      module_function

      extend Dry::Monads::Either::Mixin

      # Head of bitcoin message
      Head = Struct.new(:cmd, :length, :checksum)
      # Just command and content
      Msg = Struct.new(:cmd, :payload)
      # Reads data from socket and wrap to Either monad
      # 1. Read first 4 bytes and validate magic
      # 2. Read next 20 bytes and struct message head(command, lenght, checksum)
      # 3. Read next head.length bytes and compare checksum with
      #   first 4 bytes of sha256(sha256(payload))
      # @see https://bitcoin.org/en/developer-reference#p2p-network
      # @see https://bitcoin.org/en/developer-reference#message-headers
      def read_and_parse(network, stream)
        read_magic(network.magic, stream)
          .fmap { read_head(stream) }
          .bind do |head|
            read_payload(head, stream).fmap { |pl| parse_message(head, pl) }
          end
      end

      def read_magic(magic, stream)
        stream.recv(4) == magic ? Right(true) : Left("Wrong magic")
      end

      def read_head(stream)
        Head.new(*stream.recv(20).unpack("A12Va4"))
      end

      def read_payload(head, stream)
        payload = stream.recv(head.length)
        if BTC.hash256(payload)[0...4] == head.checksum
          Right(payload)
        else
          Left("Checksum and hash256(payload) a mismatch")
        end
      end

      def parse_message(head, payload)
        Msg.new(head.cmd.to_sym, payload)
      end
    end
  end
end
