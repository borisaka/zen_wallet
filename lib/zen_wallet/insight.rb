# frozen_string_literal: true
require_relative "insight/client"
require_relative "insight/transformation"
require_relative "insight/transaction"
require_relative "insight/balance"
module ZenWallet
  class Insight
    BITCORE_MAINNET = "https://blockexplorer.com"
    BITCORE_TESTNET = "https://testnet.blockexplorer.com"
    # MAX_ADDRESSES_REQ = 100
    def initialize(account, network)
      @account = account
      @addresses = @account.pluck_addresses
      @free_addresses = @account.load_gap_addresses
      @network = network
      @client = insight_client
    end

    def transactions(from = 0, to = 20)
      txs_json = @client.tx_history(addresses_string, from, to)
      tx_page = Transformation::TxPageTransform.call(txs_json)
      tx_page.txs.map { |tx| init_fettched_tx(tx) }
    end

    def utxo
      utxo_json = @client.utxo(addresses_string)
      Transformation::UtxoTransform.call(utxo_json)
    end

    private

    def addresses_string
      @addresses.join(",")
    end

    def insight_client
      bitcore_url = @network.testnet? ? BITCORE_TESTNET : BITCORE_MAINNET
      Insight::Client.new(bitcore_url)
    end
  end
end
