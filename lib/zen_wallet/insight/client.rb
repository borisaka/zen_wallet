# frozen_string_literal: true
require "addressable"
require "faraday"
require "json"
require_relative "mappers"

module ZenWallet
  # Client for block explorer
  module Insight
    # Client for blockexplorer api
    class Client
      attr_reader :faraday
      def initialize(bitcore_address = "https://blockexplorer.com")
        @faraday = Faraday.new(bitcore_address)
      end

      def balance(address)
        get("addr/#{address}")
      end

      def utxo(address)
        get("addr/#{address}/utxo")
      end

      def raw_tx(txid)
        post("rawtx/#{txid}")[:rawtx]
      end

      def tx_history(address, from, to)
        # query_template = Addressable::Template.new("{?from,to}")
        # query = query_template.expand(from: from, to: to)
        get("addrs/#{address}/txs?from=#{from}&to=#{to}")
      end

      def tx_history_all(address)
        txs = []
        from = 0
        to = 10
        begin
          page = tx_history(address, from, to)
          txs += Mappers::TxMapper.new.call(page[:items])
          from += 10
          to = [(to + 10), page[:totalItems]].min
        end until page[:to] >= page[:totalItems]
        txs
      end

      def broadcast_tx(tx)
        post("tx/send", rawtx: tx)
      end

      private

      def get(endpoint)
        process faraday.get("/api/#{endpoint}").body
      end

      def post(endpoint, data)
        response = faraday.post do |req|
          req.url "/api/#{endpoint}"
          req.headers["Content-Type"] = "application/json"
          req.body = JSON.dump(data)
        end
        response.body
      end

      def process(source)
        JSON.parse(source, symbolize_names: true)
      end
    end
  end
end
