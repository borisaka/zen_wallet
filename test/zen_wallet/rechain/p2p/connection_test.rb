require "test_helper"
require "zen_wallet/rechain/p2p/connection"
module ZenWallet
  module Rechain
    class ConnectionTest < Minitest::Test
      include Dry::Monads::Either::Mixin
      # class FakeMes < Msg::AbstractMsg; end
      def setup
        @network = Network.testnet
        @host, @port = "localhost", @network.default_port
        @socket = mock
        @socket.responds_like_instance_of(TCPSocket)
        @socket.stubs(:write).once
        TCPSocket.stubs(:new).with(@host, @port).returns(@socket)
        MsgParser.stubs(:read_and_parse)
                 .with(@socket)
                 .returns(Right(MsgParser::Msg.new(:verack, nil)))
        @subject = Connection.new(@host, @port, @network)
      end

      def test_receive
        # Success
        verack = MsgParser::Msg.new(:verack, nil)
        MsgParser.stubs(:read_and_parse).with(@socket).returns(Right(verack))
        @subject.expects(:handle).with(verack)
        @subject.receive
        # Fail
        fake_log = mock
        fake_log.responds_like_instance_of(Logger)
        @subject.instance_variable_set("@logger", fake_log)
        MsgParser.expects(:read_and_parse).with(@socket).returns(Left("NO"))
        fake_log.expects(:error).with("Could nod parse command: NO")
        @subject.receive
      end

      def test_gen_and_send_msg
        fake_ver = mock
        fake_ver.responds_like_instance_of(Msg::Version)
        fake_ver.stubs(:generate).returns("DATA")
        @subject.instance_variable_get("@container")
                .stubs(:resolve).with(:version).returns(fake_ver)
        @socket.expects(:write).with("DATA")
        @subject.gen_and_send_msg(:version)
      end

      def test_handle
        va_handler = mock
        va_handler.responds_like_instance_of(Msg::Verack)
        va_handler.stubs(:handle)
        stc = Dry::Container.new
        stc.register(:verack, va_handler)
        @subject.instance_variable_set("@container", stc)
        Concurrent::Future.execute { @subject.wait(:verack) }
        # @subject.expects(:remove_waiter).with(:msg, :verack)
        @subject.send(:handle, MsgParser::Msg.new(:verack, nil))
      end
    end
  end
end
