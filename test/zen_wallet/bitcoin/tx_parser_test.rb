require "test_helper"
require "zen_wallet/bitcoin/tx_parser"
module ZenWallet
  module Bitcoin
    class TxParserTest < Minitest::Test
      def setup
        tx0 = File.read("#{__dir__}/tx0.bin")
        tx1 = File.read("#{__dir__}/tx1.bin")
        tx2 = File.read("#{__dir__}/tx2.bin")
        @tx1_id =
          "a79651c687aa1b88726b0a3543807505f1cb87249ddf10ab294697a517df86f9"
        @tx2_id =
          "126dd85a5ec547af095a8ac63ef7a4b7e05f510e1d0c4bcf90e7b119036339d7"
        @btc_tx = BTC::Transaction.new(data: tx0)
        @btc_tx1 = BTC::Transaction.new(data: tx1)
        @btc_tx2 = BTC::Transaction.new(data: tx2)
        loader = mock
        loader.stubs(:load_txs).with([@tx1_id, @tx2_id]).yields([tx1, tx2])
        @parser = TxParser.new(BTC::Network.testnet, loader)
      end

      def test_parse_output
        output = @btc_tx.outputs[0]
        expected = Insight::Models::TxOut.new(
          type: "pubkeyhash",
          amount: 100_000,
          address: "mtnbGqQDBT2EFEWS59q6PWLaXbrvJDXVjd",
          n: output.index,
          script: output.script.to_hex
        )
        assert_equal expected, @parser.parse_output(output)
      end

      def test_process_inputs
        er = Class.new(StandardError)
        inputs = @btc_tx.inputs
        # Fake for prevent cycling mocha
        @parser.stubs(:parse_inputs)
               .with(@btc_tx.inputs, equals([@btc_tx1, @btc_tx2]))
               .raises(er)
        assert_raises(er) { @parser.process_inputs(inputs) }
        # assert_equal expected, @parser.process_inputs(inputs)
      end

      def test_parse_inputs
        expected = [
          Insight::Models::TxIn.new(
            txid: @tx1_id,
            vout: 1,
            n: 0,
            address: "n1osaFBa1jpZbKEM4EbRPvC6XhKb5KZsbj",
            amount: 5_850_000
          ),
          Insight::Models::TxIn.new(
            txid: @tx2_id,
            vout: 1,
            n: 1,
            address: "mh5dAqG3p7bdKqrgipJyBM2T1WKsagBeZr",
            amount: 900_000
          )
        ]
        assert_equal expected,
                     @parser.parse_inputs(@btc_tx.inputs, [@btc_tx1, @btc_tx2])
      end
    end
  end
end
