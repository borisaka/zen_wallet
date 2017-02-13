# frozen_string_literal: true
require "test_helper"
require "webmock/minitest"
require "faker"
require "zen_wallet/insight/client"

module ZenWallet
  class Insight
    class ClientTest < Minitest::Test
      def setup
        bitcore_link = "https://#{Faker::Internet.domain_name}"
        @client = Client.new(bitcore_link)
        @base_url = "#{bitcore_link}/api"
        @addresses = "1,2,3"
        @body = JSON.dump(stub: true)
        @result = { "stub" => true }
        @js_header = { "Content-Type" => "application/json" }
      end

      def test_txs
        req = stub_request(:post, "#{@base_url}/addrs/txs")
              .with(body: JSON.dump(addrs: @addresses, from: 2, to: 11),
                    headers: @js_header)
              .to_return(body: @body)
        assert_equal @result, @client.txs(@addresses, 2, 11)
        assert_requested req
      end

      def test_utxo
        req = stub_request(:post, "#{@base_url}/addrs/utxo")
              .with(body: JSON.dump(addrs: @addresses), headers: @js_header)
              .to_return(body: @body)
        assert_equal @result, @client.utxo(@addresses)
        assert_requested req
      end

      def test_broadcast_tx
        req = stub_request(:post, "#{@base_url}/tx/send")
              .with(body: JSON.dump(rawtx: "1234"))
              .to_return(body: @body)
        assert_equal @result, @client.broadcast_tx("1234")
        assert_requested req
      end
    end
  end
end
