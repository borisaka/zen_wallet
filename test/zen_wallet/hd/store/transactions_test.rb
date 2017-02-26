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
          stamps = [Time.now - 40, Time.now, Time.now + 40]
          assert_empty @transactions.load
          stamps.each do |stamp|
            r.table("transactions")
             .insert(wallet: @wid, account: @idx, time: stamp).run(@conn)
          end
          assert_equal stamps.map(&:to_i).reverse,
                       @transactions.load.map { |i| i["time"].to_i }
        end

        def test_compare_and_save
          tx = Struct.new(:txid, :wallet, :account)
          ids = %w(tx1 tx2 tx3)
          ids.each do |id|
            r.table("transactions").insert(txid: id,
                                           wallet: @wid,
                                           account: @idx).run(@conn)
          end
          build = ->(txid) { tx.new(txid, @wid, @idx) }
          # If nothing affekted
          result = @transactions.compare_and_save([build["tx2"], build["tx1"]])
          assert_equal 3, r.table("transactions").count.run(@conn)
          assert_equal [], result
          # If only new
          new_txs = [build["tx4"]]
          result = @transactions.compare_and_save(new_txs)
          assert_equal 4, r.table("transactions").count.run(@conn)
          assert_equal new_txs, result
          # If something added
          new_tx = build["tx5"]
          new_txs = [build["tx4"], new_tx, build["tx3"]]
          result = @transactions.compare_and_save(new_txs)
          assert_equal 5, r.table("transactions").count.run(@conn)
          assert_equal [new_tx], result
        end
      end
    end
  end
end
