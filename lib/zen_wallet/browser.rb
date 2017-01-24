# frozen_string_literal: true
require "faraday"
require "json"

module ZenWallet
  # Client for block explorer
  class Browser
    attr_reader :faraday
    def initialize
      @faraday = Faraday.new("https://blockexplorer.com")
    end

    def balance(address)
      request(:get, "addr/#{address}")
    end

    def utxo(address)
      request(:get, "addr/#{address}/utxo")
    end

    def raw_tx(txid)
      request(:get, "rawtx/#{txid}")[:rawtx]
    end

    def broadcast_tx(rawtx)
      request(:post, "tx/send", body: "rawtx: #{rawtx}")
    end
    # def transactions(address)
    #   request(:get, "addrs/#{address}/txs")
    # end

    private

    def request(method, endpoint, **options)
      cleaned_endpoint = endpoint.gsub(%r{^\/}, "")
      body =
        case method
        when :get
          faraday.public_send(method, "/api/#{cleaned_endpoint}").body
        when :post
          faraday.public_send(method,
                              "/api/#{cleaned_endpoint}",
                              options[:body]).body
        end
      symbolize_keys(JSON.parse(body))
    end

    def symbolize_keys(source)
      case source
      when Hash then Hash[source.map { |k, v| [k.to_sym, v] }]
      when Array then source.map { |elem| symbolize_keys(elem)}
      else
        source
      end
    end
  end
end
