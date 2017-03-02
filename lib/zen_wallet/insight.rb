# frozen_string_literal: true
require "dry-monads"
require_relative "insight/client"
require_relative "insight/transformation"
require_relative "insight/transformation/tx_decorator"
# require_relative "insight/transaction"
# require_relative "insight/balance"
# "https://test-insight.bitpay.com/"
module ZenWallet
  # Realtime Bitcore insight fettcher
  class Insight
    MAX_PAGE_SIZE = 50
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
      return [] if @addresses.empty?
      page = @client.txs(addresses_string, from, to)
      # page = Transformation::TxPageTransform.call(txs_json)
      txs = Transformation.TxDecorator(@account.wallet_id,
                                       @account.index,
                                       addresses_string,
                                       page["items"])
      Models::TxPage.new(from: page["from"],
                         to: page["to"],
                         count: page["totalItems"],
                         txs: txs)
    end

    # Smart fetch txs history
    #  breaks when all pages fetched or block yields nil or empty container
    def fetch_history
      from, to = 0, 1
      loop do
        # Monkey fiz fibonacci to real life
        to = 3 if to == 2
        to = 6 if to == 4
        puts "FROM #{from} TO: #{to}"
        if from < to
          page = transactions(from, to)
          break if page.txs.length.zero?
          break unless (yield page.txs)&.length&.positive?
        else
          puts "SKIP"
        end
        from, to = to, from + [to, MAX_PAGE_SIZE].min
        # to = to == from ? to + 1 : to
      end
    end

    # Fetch map UTXO
    def balance
      # return nil if @addresses.empty?
      ut = @client.utxo(addresses_string)
      Transformation::BalanceTransform.call(ut)
    end

    # Broadcast btc transaction
    # param rawtx [String] hex of transaction
    def broadcast(rawtx)
      @client.broadcast_tx(rawtx)["txid"]
    end

    private

    def addresses_string
      @addresses.join(",")
    end

    def insight_client
      Insight::Client.new(@network)
    end
  end
end
