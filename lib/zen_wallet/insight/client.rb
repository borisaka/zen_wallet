# frozen_string_literal: true
require "net/http"
require "json"
require "uri"
require_relative "client/balancer"
module ZenWallet
  class Insight
    # Client for bitcore insight api
    # @api private
    class Client
      extend Forwardable
      def_delegators :@network, :testnet?, :main_net?
      def_delegators Balancer, :testnet_api_link, :mainnet_api_link

      def initialize(bitcoin_network)
        @network = bitcoin_network
      end

      def utxo(addresses)
        post("addrs/utxo", addrs: addresses)
      end

      def txs(addresses, from, to)
        # binding.pry
        post("addrs/txs", addrs: addresses, from: from, to: to)
      end

      def broadcast_tx(tx)
        post("tx/send", rawtx: tx)
      end

      private

      def working_uri(endpoint)
        link = testnet? ? Balancer.testnet_api_link : Balancer.mainnet_api_link
        #  = @network.testnet? ? test_net_uri : main_net_uri
        cleaned = endpoint.gsub(%r{^\/}, "")
        URI.parse(format("%s%s/%s", link.host_url, link.base_path, cleaned))
      end

      def post(endpoint, data)
        uri = working_uri(endpoint)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post
                  .new(uri.request_uri,
                       "Content-Type" => "application/json",
                       "Accept" => "application/json")
        request.body = JSON.dump(data)
        response = http.request(request)
        process(response.body)
      end

      def process(source)
        JSON.parse(source)
      end
    end
  end
end
