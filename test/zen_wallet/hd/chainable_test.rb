# frozen_string_literal: true
require "test_helper"
# require "btcruby"
require "zen_wallet/hd/chainable"
module ZenWallet
  module HD
    class ChainableTest < Minitest::Test
      def setup
        @store = mock
        @container = Dry::Container.new
        @container.register("store.chainables", @store)
        @xpub = BTC::Keychain.new(seed: SecureRandom.hex).xpub
        @chainable =
          Chainable.new(@container, id: "1234", xprv: nil, xpub: @xpub)
      end

      def test_lookup
        @store.expects(:lookup).with(id: "1234")
              .returns(xprv: nil, xpub: @xpub)
        ch = Chainable.lookup(@container, id: "1234")
        assert_equal @chainable, ch
      end
    end
  end
end
