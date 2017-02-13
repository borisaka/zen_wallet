# frozen_string_literal: true
require_relative "insight/client"
require_relative "insight/transformation"
# require_relative "insight/transaction"
# require_relative "insight/balance"
module ZenWallet
  # Realtime Bitcore insight fettcher
  class Insight
    BITCORE_MAINNET = "https://blockexplorer.com"
    BITCORE_TESTNET = "https://testnet.blockexplorer.com"
    # MAX_ADDRESSES_REQ = 100
    # @param network [BTC::Network] which bitcoin network to connect
    # @param addresses [HD::Account] list of addresses to watch
    def initialize(network, addresses)
      @addresses = addresses
      @network = network
      @client = insight_client
    end

    def transactions(from = 0, to = 20)
      fetch_txs_page(from, to)
    end

    # Fetch map UTXO
    def balance
      utxo_json = @client.utxo(addresses_string)
      Transformation::BalanceTransform.call(utxo: utxo_json)
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
    end

    def addresses_string
      @addresses.join(",")
    end

    def insight_client
      bitcore_url = @network.testnet? ? BITCORE_TESTNET : BITCORE_MAINNET
      Insight::Client.new(bitcore_url)
    end
  end
end
