# frozen_string_literal: true
require "test_helper"
require "faker"
require "zen_wallet/bitcoin/explorer/connection_pool"

module ZenWallet
  module Bitcoin
    class ConnectionPoolTest < Minitest::Test
      def setup
        ::Bitcoin.network = :testnet3
        @pool = ConnectionPool.new(5, BTC::Network.testnet)
        ips = Array.new(5) { Faker::Internet.ip_v4_address }
        conns = Array.new(5) { mock.responds_like_instance_of(Connection) }
        IPSocket.stubs(:getaddress)
                .with(any_of(*ConnectionPool::TESTNET_SEEDS))
                .returns(*ips).times(5)
        EM.stubs(:connect)
          .with(any_of(*ips), 18_333, Connection)
          .returns(*conns).times(5)
        @pool.start
      end

      def test_start
        assert_equal 5, @pool.contents.length
      end

      def test_stop
        contents.each { |m| m.expects(:close_connection) }
        @pool.stop
        assert_empty @pool.instance_variable_get("@resources")
        assert_empty @pool.instance_variable_get("@contents")
      end

      private

      def contents
        @pool.instance_variable_get("@contents")
      end

      # def teardown
      # end
    end
  end
end
