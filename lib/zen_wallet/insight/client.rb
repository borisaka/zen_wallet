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
      def_delegators Balancer, :test_net_uri, :main_net_uri

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

      def working_uri(enpoint)
        api_link = testnet? ? Balancer.test_net_uri : Balancer.main_net_uri
        #  = @network.testnet? ? test_net_uri : main_net_uri
        uri = URI.parse("#{api_link.host_url}/#{api_link.base_path}")
        uri.merge(enpoint)
      end

      def post(endpoint, data)
        uri = working_uri(endpoint)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post
                  .new(uri.request_uri, "Content-Type" => "application/json")
        request.body = JSON.dump(data)
        response = http.request(request)
        puts(response.body)
        process(response.body)
      end

      def process(source)
        JSON.parse(source)
      end
    end
  end
end
