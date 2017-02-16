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
           ApiLink.new("https://test-insight.bitpay.com", "/api/")].freeze
        MAINNET = [ApiLink.new("https://blockexplorer.com", "/api/"),
                   ApiLink.new("https://bitcore1.trezor.io", "/api/"),
                   ApiLink.new("https://bitcore2.trezor.io", "/api/"),
                   ApiLink.new("https://bitcore3.trezor.io", "/api/"),
                   ApiLink.new("https://www.localbitcoinschain.com", "/api")
                   ].freeze
        def testnet_api_link
          TESTNET.sample
        end

        def mainnet_api_link
          MAINNET.sample
        end
      end
    end
  end
end
