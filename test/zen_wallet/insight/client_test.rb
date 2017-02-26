# frozen_string_literal: true
require "test_helper"
require "webmock/minitest"
require "faker"
require "zen_wallet/insight/client"

module ZenWallet
  class Insight
    class ClientTest < Minitest::Test
      # @todo test balancer
      def setup
        network = BTC::Network.testnet
        uri = URI.parse(Faker::Internet.url)
        uri.scheme = "https"
        bitcore_link = OpenStruct.new(
          host_url: "https://#{uri.host}",
          base_path: uri.path
        )
        Client::Balancer.stubs(:testnet_api_link).returns(bitcore_link)
        @req_headers = { "Accept" => "application/json",
                         "Accept-Encoding" =>
                            "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
                         "Content-Type" => "application/json",
                         "User-Agent" => "Ruby" }
        @client = Client.new(network)
        @base_url = uri.to_s
        @addresses = "1,2,3"
        @body = JSON.dump(stub: true)
        @result = { "stub" => true }
        # @js_header = { "Content-Type" => "application/json" }
      end

      def test_txs
        req = stub_request(:post, "#{@base_url}/addrs/txs")
              .with(body: JSON.dump(addrs: @addresses, from: 2, to: 11),
                    headers: @req_headers)
              .to_return(body: @body)
        assert_equal @result, @client.txs(@addresses, 2, 11)
        assert_requested req
      end

      def test_utxo
        req = stub_request(:post, "#{@base_url}/addrs/utxo")
              .with(body: JSON.dump(addrs: @addresses), headers: @req_headers)
              .to_return(body: @body)
        assert_equal @result, @client.utxo(@addresses)
        assert_requested req
      end

      def test_broadcast_tx
        req = stub_request(:post, "#{@base_url}/tx/send")
              .with(body: JSON.dump(rawtx: "1234"), headers: @req_headers)
              .to_return(body: @body)
        assert_equal @result, @client.broadcast_tx("1234")
        assert_requested req
      end
    end
  end
end
