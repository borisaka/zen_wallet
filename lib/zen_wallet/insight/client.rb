# frozen_string_literal: true
require "addressable"
require "faraday"
require "json"
# require_relative "mappers"

module ZenWallet
  # Client for block explorer
  class Insight
    # Client for blockexplorer api
    class Client
      attr_reader :faraday
      def initialize(bitcore_address)
        @faraday = Faraday.new(bitcore_address)
      end

      def utxo(addresses)
        post("addrs/utxo", addrs: addresses)
      end

      def tx_history(addresses, from, to)
        post("addrs/txs", addrs: addresses, from: from, to: to)
      end

      def broadcast_tx(tx)
        post("tx/send", rawtx: tx)
      end

      private

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
