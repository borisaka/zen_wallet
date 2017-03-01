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

        def test_merge_defaults
          tx = r(txid: "tx0")
          out = r(n: 0)
          expected = { id: "tx0.0",
                       txid: "tx0",
                       wallet: "id",
                       account: 0,
                       n: 0 }
          assert_equal stringify_keys(expected),
                       @utxo.send(:merge_defaults, tx[:txid], out).run(@conn)
        end

        def test_update
          new_txs = [acc_tx("tx0", outputs: [{ n: 3 }],
                                   inputs: { txid: "tx1", n: 4 })]
          # inserts
          # create_utxo("tx1", 4)
          @utxo.update(new_txs)
          expected = expected_outputs(new_txs)
          assert_equal expected, all
          # ignores spent
          new_tx = acc_tx("tx1", outputs: [{ spent_tx_id: "tx0", n: 3 }])
          @utxo.update([new_tx])
          assert_equal expected, all
        end

        def test_find_and_remove_spent
          expected = create_utxo("tx1", 4)
          create_utxo("tx1", 3)
          create_tx(txid: "tx2",
                    account_detail: { inputs: [txid: "tx1", n: 3] })
          @utxo.find_and_remove_spent
          assert_equal [expected], all
        end

        # def test_update_from_txs
        #   items = [
        #     { "wallet" => @wid, "account" => @idx, "txid" => "tx0", "n" => 0,
        #       "amount" => 3, address: "0"},
        #     { "wallet" => @wid, "account" => @idx, "txid" => "tx0", "n" => 1,
        #       "amount" => 2, address: "1" }
        #   ]
        #   r.table("utxo").insert(items).run(@conn)
        #   txs = [
        #     Struct.new(:txid, :account_detail).new(
        #       "tx1",
        #       Struct.new(:inputs, :outputs)
        #             .new([Struct.new(:txid, :vout).new("tx0", 1)],
        #                  [Struct.new(:amount, :address, :n, :type, :script)
        #                         .new(1, "3", 0, "pk", "pkver")])
        #     )
        #   ]
        #   @utxo.update_from_txs(txs)
        #   assert_equal 2, r.table("utxo").count.run(@conn)
        #   expected = { "amount" => 1,
        #                "address" => "3",
        #                "txid" => "tx1",
        #                "n" => 0,
        #                "type" => "pk",
        #                "script" => "pkver",
        #                "wallet" => @wid,
        #                "account" => @idx }
        #   last = r.table("utxo")
        #           .get_all(["tx1", 0], index: "txid_and_n")
        #           .run(@conn).first
        #   last.delete("id")
        #   assert_equal expected, last
        # end

        def w
          { wallet: @wid, account: @idx }
        end

        def create_utxo(txid, n, **attrs)
          done_attrs = { id: "#{txid}.#{n}", txid: txid, n: n }
                       .merge(w)
                       .merge(attrs)
          r.table("utxo").insert(done_attrs).run(@conn)
          stringify_keys(done_attrs)
        end

        def test_balance
          items = [
            { "wallet" => @wid, "account" => @idx, "txid" => "tx0", "n" => 0,
              "amount" => 3, address: "0" },
            { "wallet" => @wid, "account" => @idx, "txid" => "tx0", "n" => 1,
              "amount" => 2, address: "1" }
          ]
          r.table("utxo").insert(items).run(@conn)
          assert_equal 5, @utxo.balance
        end

        private

        # def

        def acc_tx(txid, inputs: [], outputs: [])
          {
            txid: txid,
            account_detail: { inputs: inputs, outputs: outputs }
          }
        end

        def expected_outputs(txs)
          outs = txs.map do |tx|
            tx[:account_detail][:outputs].map do |out|
              out.merge(id: "#{tx[:txid]}.#{out[:n]}",
                        wallet: @wid,
                        account: @idx,
                        txid: tx[:txid])
            end
          end
          outs.map { |out| stringify_keys(out) }.flatten
        end

        def all
          r.table("utxo").run(@conn).to_a
        end
      end
    end
  end
end
