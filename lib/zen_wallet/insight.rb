# frozen_string_literal: true
require "dry-monads"
require_relative "insight/client"
require_relative "insight/transformation"
# require_relative "insight/transaction"
# require_relative "insight/balance"
# "https://test-insight.bitpay.com/"
module ZenWallet
  # Realtime Bitcore insight fettcher
  class Insight
    include Dry::Monads::Try::Mixin
    include Dry::Monads::Either::Mixin
    include Dry::Monads::Maybe::Mixin
    # https://test-insight.bitpay.com/
    # MAX_ADDRESSES_REQ = 100
    # @param network [BTC::Network] which bitcoin network to connect
    # @param addresses [HD::Account] list of addresses to watch
    def initialize(network, account, addresses)
      @account = account
      @addresses = addresses
      @network = network
      @client = insight_client
    end

    def transactions(from = 0, to = 20)
      page = fetch_txs_page(from, to)
      # Transformation::TxAccountInfo(@account.wallet_id,
      #                               @account.id,
      #                               @addresses,
      #                               page[:txs])
    end

    # Fetch map UTXO
    def balance
      Maybe(@client.utxo(addresses_string)).bind do |hsh|
           Transformation::BalanceTransform.call(hsh)
      end
    end

    # Broadcast btc transaction
    # param rawtx [String] hex of transaction
    def broadcast(rawtx)
      @client.broadcast_tx(rawtx)["txid"]
    end

    private

    def fetch_txs_page(from, to)
      txs_json = @client.txs(addresses_string, from, to)
      Transformation::TxPageTransform.call(txs_json)
      warn "CLient does not working"
    end

    def addresses_string
      @addresses.join(",")
    end

    def insight_client
      Insight::Client.new(@network)
    end
  end
end
