# frozen_string_literal: true
require "addressable"
require "faraday"
require "json"

module ZenWallet
  class Insight
    # Client for bitcore insight api
    # @api private
    class Client
      attr_reader :faraday
      def initialize(bitcore_address)
        @faraday = Faraday.new(bitcore_address)
      end

      def utxo(addresses)
        post("addrs/utxo", addrs: addresses)
      end

      def txs(addresses, from, to)
        post("addrs/txs", addrs: addresses, from: from, to: to)
      end

      def broadcast_tx(tx)
        post("tx/send", rawtx: tx)
      end

      private

      # unused, but keeped
      def get(endpoint)
        process(faraday.get("/api/#{endpoint}").body)
      end

      def post(endpoint, data)
        response = faraday.post do |req|
          req.url "/api/#{endpoint}"
          req.headers["Content-Type"] = "application/json"
          req.body = JSON.dump(data)
        end
        process(response.body)
      end

      def process(source)
        JSON.parse(source)
      end
    end
  end
end
