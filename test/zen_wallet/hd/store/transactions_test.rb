# frozen_string_literal: true
require_relative "../test_helper"
module ZenWallet
  module HD
    class Store
      class TransactionsTest < BaseStoreTest
        def setup
          super
          @transactions = @store.transactions
        end

        def test_load
          stamps = [Time.now - 40, Time.now, Time.now + 40, Time.now - 20]
          assert_empty @transactions.load
          stamps[0..-2].each { |stamp| create_tx(time: stamp, confirmed: true) }
          create_tx(time: stamps[-1], confirmed: false)
          assert_equal [stamps[-1].to_i] + stamps[0..-2].map(&:to_i).reverse,
                       @transactions.load.map { |i| i["time"].to_i }
        end

        def test_compare_and_save
          tx = build_tx(txid: "tx0", confirmed: false, confirmations: 0)
          expected = [stringify_keys(tx)]
          # Inserts new
          assert_equal expected, @transactions.compare_and_save([tx])
          assert_equal expected, txs
          # Updates exists
          tx = tx.merge("confirmed" => true, "confirmations" => 43)
          expected = [stringify_keys(tx)]
          assert_equal [], @transactions.compare_and_save([tx])
          assert_equal expected, txs
        end

        private

        def txs(filter: nil, without: nil, run: true)
          q = r.table("transactions")
          q = q.filter(filter) if filter
          q = q.map { |tx| tx.without(r.args(without)) } if without
          q.run(@conn).to_a if run
        end

      end
    end
  end
end
