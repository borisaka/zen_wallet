# frozen_string_literal: true
require_relative "../test_helper"
module ZenWallet
  module HD
    class Store
      class UtxoTest < BaseStoreTest
        def setup
          super
          @utxo = @store.utxo
        end

        def test_load
          # binding.pry
          items = [
            { "wallet" => @wid, "account" => @idx, "txid" => "tx0", "n" => 0 },
            { "wallet" => @wid, "account" => @idx, "txid" => "tx0", "n" => 1 }
          ]
          assert_empty @utxo.load
          r.table("utxo").insert(items).run(@conn)
          assert_equal items, (@utxo.load.map do |u|
            u.delete("id")
            u
          end.sort_by { |h| h["n"] })
        end

        def test_update_from_txs
          items = [
            { "wallet" => @wid, "account" => @idx, "txid" => "tx0", "n" => 0,
              "amount" => 3, address: "0"},
            { "wallet" => @wid, "account" => @idx, "txid" => "tx0", "n" => 1,
              "amount" => 2, address: "1" }
          ]
          r.table("utxo").insert(items).run(@conn)
          txs = [
            Struct.new(:txid, :account_detail).new(
              "tx1",
              Struct.new(:inputs, :outputs)
                    .new([Struct.new(:txid, :vout).new("tx0", 1)],
                         [Struct.new(:amount, :address, :n, :type, :script)
                                .new(1, "3", 0, "pk", "pkver")])
            )
          ]
          @utxo.update_from_txs(txs)
          assert_equal 2, r.table("utxo").count.run(@conn)
          expected = { "amount" => 1,
                       "address" => "3",
                       "txid" => "tx1",
                       "n" => 0,
                       "type" => "pk",
                       "script" => "pkver",
                       "wallet" => @wid,
                       "account" => @idx }
          last = r.table("utxo")
                  .get_all(["tx1", 0], index: "txid_and_n")
                  .run(@conn).first
          last.delete("id")
          assert_equal expected, last
        end

        def test_balance
          items = [
            { "wallet" => @wid, "account" => @idx, "txid" => "tx0", "n" => 0,
              "amount" => 3, address: "0"},
            { "wallet" => @wid, "account" => @idx, "txid" => "tx0", "n" => 1,
              "amount" => 2, address: "1" }
          ]
          r.table("utxo").insert(items).run(@conn)
          assert_equal 5, @utxo.balance
        end
      end
    end
  end
end
