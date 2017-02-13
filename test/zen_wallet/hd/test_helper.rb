# frozen_string_literal: true
require "test_helper"

class HDTest < Minitest::Test
  def setup
    super
    @container = Dry::Container.new
    @network = BTC::Network.mainnet
    @container.register("bitcoin_network", @network)
  end
end
