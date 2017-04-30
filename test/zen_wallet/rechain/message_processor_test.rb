require "test_helper"
require "zen_wallet/rechain/message_processor"
module ZenWallet
  module Rechain
    class MessageProcessorTest < Minitest::Test
      def setup
        @payload = payload
        @checksum = ["!\xBE\xD8\a"].pack("a*")
        @magic = ["\v\x11\t\a"].pack("a*")
        @len = 103
        @pkt = pkt
        @subject = MessageProcessor.new(@magic)
        @msg = MessageProcessor::Msg.new(msg_type: :version, payload: @payload)
      end

      def test_generate
        assert_equal @pkt, @subject.gen_msg(@msg)
      end

      def test_receive_msg
        stream = mock
        stream.responds_like_instance_of(TCPSocket)
        # Fail magic
        stream.expects(:recv).with(4).returns("00")
        assert_raises MessageProcessor::BadMagic do
          @subject.receive_msg(stream)
        end
        # Fail payload
        stream.expects(:recv).with(4).returns(@magic)
        stream.expects(:recv).with(20).returns(@pkt[4..24])
        stream.expects(:recv).with(103).returns("00")
        assert_raises MessageProcessor::ChecksumMismatch do
          @subject.receive_msg(stream)
        end
        # Success
        stream.expects(:recv).with(4).returns(@magic)
        stream.expects(:recv).with(20).returns(@pkt[4..24])
        stream.expects(:recv).with(103).returns(@payload)
        assert_equal @msg, @subject.receive_msg(stream)
      end

      private

      def pkt
        ["\v\x11\t\aversion     g\x00\x00\x00!\xBE\xD8\a\x7F\x11\x01\x00\t\x00"\
         "\x00\x00\x00\x00\x00\x00c\xAA\xC7X\x00\x00\x00\x00\x00\x00\x00\x00"\
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xFF\xFF_T"\
         "\xB6M\xA6\x04\t\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"\
         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x001i]\x99Q\x9F\xDC$"\
         "\x11/Satoshi:0.13.99/\xD6\xAF\x10\x00\x01"].pack("a*")
      end

      def payload
        ["\x7F\x11\x01\x00\t\x00\x00\x00\x00\x00\x00\x00c\xAA\xC7X"\
        "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"\
        "\x00\x00\x00\x00\x00\x00\x00\x00\xFF\xFF_T\xB6M\xA6\x04\t"\
        "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"\
        "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x001i]\x99Q\x9F"\
        "\xDC$\x11/Satoshi:0.13.99/\xD6\xAF\x10\x00\x01"].pack("a*")
      end
    end
  end
end
