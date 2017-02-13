# frozen_string_literal: true
require "test_helper"
require "zen_wallet/insight/models"
require "zen_wallet/insight/transformation"
module ZenWallet
  class Insight
    module Transformation
      class TransformationTest < Minitest::Test
        def setup
          @outputs =
            [{ "value" => "0.35421355", "n" => 0,
               "scriptPubKey" => { "addresses" => ["3"], "hex" => "script",
                                   "type" => "tx" } }]
          @inputs = [{ "txid" => "input", "vout" => 2, "n" => 0,
                       "addr" => "3K9NiLPRsTyz2EWgPEC2PGPwpKV9ySkA9o",
                       "valueSat" => 25_383_649, "scriptSig" => "s" }]
          @transaction = {
            "txid" => "tx", "vin" => @inputs, "vout" => @outputs,
            "confirmations" => 0, "time" => 1_485_561_166, "blocktime" => nil
          }
          @page = { "from" => 0, "to" => 10,
                    "totalItems" => 1, "items" => [@transaction] }
          @utxo = [{ "address" => "1", "txid" => "2", "vout" => 0,
                     "amount" => 0.1, "satoshis" => 10_000_000,
                     "scriptPubKey" => "script" }]

          @parsed_input =
            Models::TxIn.new(txid: "input", vout: 2, n: 0,
                             address: "3K9NiLPRsTyz2EWgPEC2PGPwpKV9ySkA9o",
                             amount: 25_383_649)
          @parsed_output =
            Models::TxOut.new(n: 0, amount: 35_421_355, script: "script",
                              type: "tx", address: "3")
          @parsed_tx =
            Models::Tx.new(txid: "tx", confirmations: 0,
                           time: Time.parse("2017-01-28T02:52:46+03:00"),
                           blocktime: nil, inputs: [@parsed_input],
                           outputs: [@parsed_output])
          @parsed_tx_page =
            Models::TxPage.new(from: 0, to: 10, total: 1, txs: [@parsed_tx])
        end
        def test_tx_in_transform
          assert_equal @parsed_input, TxInTransform.call(@inputs.first)
        end

        def test_tx_out_transform
          assert_equal @parsed_output, TxOutTransform.call(@outputs.first)
        end

        def test_tx_transform
          assert_equal @parsed_tx, TxTransform.call(@transaction)
        end

        def test_tx_page_transform
          assert_equal @parsed_tx_page, TxPageTransform.call(@page)
        end
      end
    end
  end
end
