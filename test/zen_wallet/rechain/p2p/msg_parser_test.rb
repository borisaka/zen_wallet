# frozen_string_literal: true
require "test_helper"
require "zen_wallet/rechain/p2p/msg_parser"
require "zen_wallet/rechain/p2p/network"
require "zen_wallet/rechain/p2p/connection"
module ZenWallet
  module Rechain
    class MsgParserTest < Minitest::Test
      include Dry::Monads::Either::Mixin
      def setup
        @net = Network.testnet
        @socket = mock
        @socket.responds_like_instance_of(TCPSocket)
        @message = MsgParser::Msg.new(:version, payload)
        @checksum = "!\xBE\xD8\a".unpack("a4")[0]
        @head = MsgParser::Head.new("version", 103, @checksum)
        @subject = MsgParser
      end

      def test_handle
        stub_internals(
          parse_message: [@head, payload, [@message]],
          read_head: [@socket, [@head]],
          read_magic: [@net.magic, @socket, [Left("Wrong magic"), Right(true)]],
          read_payload: [@head, @socket, [bad_chsum, Right(payload)]]
        )
        sub = -> { @subject.read_and_parse(@net, @socket) }
        # binding.pry
        assert_equal Left("Wrong magic"), sub.call
        assert_equal bad_chsum, sub.call
        assert_equal Right(@message), sub.call
      end

      def test_read_magic
        @socket.stubs(:recv).with(4).returns("\v\x11\t\a", "00")
        sub = -> { @subject.read_magic(@net.magic, @socket) }
        assert_equal sub.call, Right(true)
        assert_equal sub.call, Left("Wrong magic")
      end

      def test_read_head
        ver = "version\x00\x00\x00\x00\x00g\x00\x00\x00!\xBE\xD8\a"
        @socket.stubs(:recv).with(20).returns(ver)
        assert_equal @head, @subject.read_head(@socket)
      end

      def test_read_payload
        @socket.stubs(:recv).with(103).returns(payload, "WRONG_STR")
        assert_equal Right(payload), @subject.read_payload(@head, @socket)
        assert_equal bad_chsum, @subject.read_payload(@head, @socket)
      end

      def test_parse_message
        assert_equal @message, @subject.parse_message(@head, payload)
      end

      private

      def stub_internals(**options)
        options.each do |k, v|
          v = [*v]
          @subject.stubs(k).with(*v[0..-2]).returns(*v[-1])
        end
      end

      def bad_chsum
        Left("Checksum and hash256(payload) a mismatch")
      end

      def payload
        "\x7F\x11\x01\x00\t\x00\x00\x00\x00\x00\x00\x00c\xAA\xC7X"\
        "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"\
        "\x00\x00\x00\x00\x00\x00\x00\x00\xFF\xFF_T\xB6M\xA6\x04\t"\
        "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"\
        "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x001i]\x99Q\x9F"\
        "\xDC$\x11/Satoshi:0.13.99/\xD6\xAF\x10\x00\x01"
      end
    end
  end
end
