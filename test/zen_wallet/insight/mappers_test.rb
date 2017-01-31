# frozen_string_literal: true
require "test_helper"
require "zen_wallet/insight/models"
require "zen_wallet/insight/mappers"
module ZenWallet
  module Insight
    class MappersTest < Minitest::Test
      def setup
        @outputs = [
          { "value" => "0.35421355", "n" => 0,
            "scriptPubKey" =>
              { "addresses" => ["3K9NiLPRsTyz2EWgPEC2PGPwpKV9ySkA9o"] } }
        ]
        @inputs = [
          {
            "txid" => "input",
            "vout" => 2,
            "n" => 0,
            "addr" => "3K9NiLPRsTyz2EWgPEC2PGPwpKV9ySkA9o",
            "value" => 0.25383649
          }
        ]
        @transactions = [{
          "txid" => "tx",
          "vin" => @inputs,
          "vout" => @outputs,
          "confirmations" => 0,
          "time" => 1_485_561_166,
          "valueIn" => 1.80338863,
          "valueOut" => 1.80268862,
          "size" => 1159,
          "fees" => 0.00070001
        }]

        @parsed_input =
          Models::TxIn.new(txid: "input", vout: 2, n: 0,
                           address: "3K9NiLPRsTyz2EWgPEC2PGPwpKV9ySkA9o",
                           satoshis: 25_383_649)
        @parsed_output =
          Models::TxOut.new(n: 0, satoshis: 35_421_355,
                            address: "3K9NiLPRsTyz2EWgPEC2PGPwpKV9ySkA9o")
        @parsed_tx =
          Models::Tx.new(txid: "tx", confirmations: 0,
                         input_sat: 180_338_863,
                         output_sat: 180_268_862,
                         time: DateTime.parse("2017-01-28T02:52:46+03:00"),
                         fees: 70_001, inputs: [@parsed_input],
                         outputs: [@parsed_output])
      end

      def test_tx_in_mapper
        assert_equal [@parsed_input],
                     Mappers::TxInMapper.new.call(@inputs)
      end

      def test_tx_out_mapper
        assert_equal [@parsed_output],
                     Mappers::TxOutMapper.new.call(@outputs)
      end

      def test_tx_mapper
        assert_equal [@parsed_tx],
                     Mappers::TxMapper.new.call(@transactions)
      end
    end
  end
end
