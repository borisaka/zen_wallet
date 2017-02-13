require "test_helper"
require "zen_wallet/insight/models"
require "zen_wallet/insight/transformation"
require_relative "asset/result.rb"
module ZenWallet
  class Insight
    module Transformation
      class UtxoTest < Minitest::Test
        def setup
          base_path = Pathname.new(__dir__).join("asset")
          @json = JSON.parse(File.read(base_path.join("utxo.json")))
          @models = PARSED_UTXO.map { |u| Models::Utxo.new(u) }
        end

        def test_utxo_transform
          6.times do |i|
            attrs = PARSED_UTXO[i]
            transformed = UtxoTransform.call(@json[i])
            assert_equal attrs, transformed
            assert_equal @models[i], Models::Utxo.new(transformed)
          end
        end

        def test_balance_transform
          model = Models::Balance.new(BALANCE_ADDITIONS)
          result_model = BalanceTransform.call(utxo: @json)
          assert_equal model, result_model
        end
      end
    end
  end
end
