# frozen_string_literal: true
require "test_helper"
require "zen_wallet/transaction_builder"
module ZenWallet
  class TransactionBuilderTest < Minitest::Test
    def setup
      @utxo = [40, 40, 120].map { |sat| { satoshis: sat } }
    end

    def test_build_transaction
      txid = "9408946083cfe1a9d0be572ca4c2fd493e475e76f3e2e600b1a3853731ccd53f"
      utxo = [{ address: "1AbzLiTqycBdeWdMSzcd3D5iwZXAeqkn3v",
                txid: txid,
                vout: 1,
                scriptPubKey: "76a914695723c38d2b6cdd0413abc0d42e93dfcf4d122788ac",
                amount: 0.025,
                satoshis: 2_500_000,
                height: 449_658,
                confirmations: 2 }]
      outputs = [
        { satoshis: 1_100_000, address: "1J6jfYbkeCkjqKHTcvR7o7j9EPerx6m2hp" },
        { satoshis: 1_200_000, address: "1J79bxhrUMsrP1oPzqjLN92GZnwv4THDbX" }
      ]
      commission = 500_000
      key_str = "eb226c93d37ea7901a5cd866369ba36e8936ea67c2a2449ff0"\
                "ed6309c61da614"
      raw_tx = "01000000025bf6d5c66144dd7bd0056bdaa9bffc7b828d8b38a9b1d520a6"\
               "9cb8fa6c991c62000000006a47304402204a0999d20b6ed67c514ac9edda"\
               "3f46ee81e0f2bc13511c20a232979f7ff538cb02206dac2debafa8929d8e"\
               "3bc64d3136d726540da43da658f51346279f27ac93086b01210296c21821"\
               "2ee0cf317acf620f4b96e5bb3756d51617b2b2b30c3775bc02b5bf66feff"\
               "fffffa82c997f0e6774d08eb4644d8936bde2fa6af28d86ba6feb7b267fa"\
               "5dc2783c010000006a47304402206bb4df15a5e70dbc78c7ef7c222457f0"\
               "8d5536a2864efa517d56a47d1079c91d0220367e6ea6b1e0e734cbcc35be"\
               "50d02e6a26ada8e74bb8876d45a45471ed3051970121038252ec0d0c5cca"\
               "77e4746b37d611cf960dbf7e3376c38442fd41596c30025edffeffffff02"\
               "ba221000000000001976a9144c350fe31afb8e85f641509259e48f2fcc1a"\
               "a07888aca0252600000000001976a914695723c38d2b6cdd0413abc0d42e"\
               "93dfcf4d122788ac56dc0600"
      Browser.any_instance.expects(:raw_tx).with(txid).returns(raw_tx)
      # Browser.any_instance.expects(:raw_tx).with("1").returns(raw_tx)
      transaction = TransactionBuilder
                    .build_transaction(utxo, outputs, commission, key_str)
    end

    def test_find_inputs
      # find small sum
      assert_equal @utxo[0..1], TransactionBuilder.find_inputs(@utxo, 75)
      # find one big
      assert_equal [@utxo[2]], TransactionBuilder.find_inputs(@utxo, 119)
      # only small
      assert_equal @utxo, TransactionBuilder.find_inputs(@utxo, 121)
      # not enough
      assert_raises "Amount too big" do
        TransactionBuilder.find_inputs(@utxo, 201)
      end
    end
  end
end
