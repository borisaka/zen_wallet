require "test_helper"
require "zen_wallet/insight/models"
require "zen_wallet/insight/transformation"
require "zen_wallet/insight/transformation/tx_decorator"
require "mixins/account"
module ZenWallet
  class Insight
    module Transformation
      class TxDecoratorTest < Minitest::Test
        include AccountMixin
        def setup
          base_path = Pathname.new(__dir__).join("asset")
          @acc = @acc_balance_model
          @json = JSON.parse(File.read(base_path.join("txs.json")))
        end

        def test_transform
          # puts @json
          my_addresses = %w(mzerjPQQMFNqoeXr2U3Sc8WWLzuvJQ9eBT
                            mw5WtLQ2wBZTMLQX5kpCYBddYdZvtSoJRQ)
          result = Transformation.TxDecorator(@acc.wallet_id,
                                              @acc.index,
                                              my_addresses,
                                              @json)
          #  result[1].to_h
          acc_detail0 = {
             inputs: [],
             outputs: [{
               address: "mzerjPQQMFNqoeXr2U3Sc8WWLzuvJQ9eBT",
               amount: 4000000,
               script: "76a91442b6248846f37190900a6d886b28fee2bf9aeee188ac",
               n: 0,
               type: "pubkeyhash"
             }]
          }
          acc_detail1 = {
            inputs: [{
              txid: "cc1e1f63a2d56d73c263e93e6315851e1f7e567de989f9b2f179efde9a004cfa",
              vout: 1,
              n: 0,
              address: "mw5WtLQ2wBZTMLQX5kpCYBddYdZvtSoJRQ",
              amount: 8970000
            }],
            outputs: [
              {
                address: "mw5WtLQ2wBZTMLQX5kpCYBddYdZvtSoJRQ",
                amount: 4870000,
                n: 1,
                script: "76a91442b6248846f37190900a6d886b28fee2bf9aeee188ac",
                type: "pubkeyhash"
              }
            ]
          }
          assert_equal 4000000, result[0].total
          assert_equal "mzerjPQQMFNqoeXr2U3Sc8WWLzuvJQ9eBT",
                       result[0].main_address
          assert_equal "mzerjPQQMFNqoeXr2U3Sc8WWLzuvJQ9eBT",
                       result[0].out_address
          assert_equal ["mzerjPQQMFNqoeXr2U3Sc8WWLzuvJQ9eBT"],
                       result[0].used_addresses
          assert_equal acc_detail0, result[0].account_detail.to_h
          assert_equal -4100000, result[1].total
          assert_equal "mw5WtLQ2wBZTMLQX5kpCYBddYdZvtSoJRQ",
                       result[1].main_address
          assert_equal "n2EJK1LoMWYvSBDmB2rsqF4F3QfngdaLkQ",
                       result[1].out_address
          assert_equal ["mw5WtLQ2wBZTMLQX5kpCYBddYdZvtSoJRQ"],
                       result[1].used_addresses
          assert_equal acc_detail1, result[1].account_detail.to_h
        end
      end
    end
  end
end
