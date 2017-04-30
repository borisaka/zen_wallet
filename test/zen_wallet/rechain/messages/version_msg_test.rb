require "test_helper"
require "zen_wallet/rechain/messages/version_msg"
module ZenWallet::Rechain::Messages
  class VersionMsgTest < Minitest::Test
    def setup
      container = Dry::Container.new
      container.register("peer.host", "::ffff:127.0.0.1")
      container.register("peer.port", 18_333)
      @subject = VersionMsg.new(container)
      Time.stubs(:now).returns(Time.at(1489668802))
      @src = [70_014, 0, 1_489_668_802]
      @pkt = "~\x11\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\xC2\x8A\xCAX\x00\x00\x00\x00" \
             ""
    end

    def test_generate

    end

  end
end
