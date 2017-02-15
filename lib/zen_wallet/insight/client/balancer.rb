# frozen_string_literal: true
module ZenWallet
  class Insight
    class Client
      # simple serivices balancer
      module Balancer
        module_function

        ApiLink = Struct.new(:host_url, :base_path)
        TESTNET =
          [ApiLink.new("https://testnet.blockexplorer.com", "/api/"),
           ApiLink.new("https://test-insight.bitpay.com/", "/api/")].freeze
        MAINNET = [ApiLink.new("https://blockexplorer.com", "/api/"),
                   ApiLink.new("https://bitcore1.trezor.io", "/api/"),
                   ApiLink.new("https://bitcore2.trezor.io", "/api/"),
                   ApiLink.new("https://bitcore3.trezor.io", "/api/"),
                   ApiLink.new("https://www.localbitcoinschain.com", "/api")
                   ].freeze
        def test_net_uri
          TESTNET.sample
        end

        def main_net_uri
          MAINNET.sample
        end
      end
    end
  end
end
