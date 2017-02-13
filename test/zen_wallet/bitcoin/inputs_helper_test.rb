# frozen_string_literal: true
require "test_helper"
require "zen_wallet/bitcoin/inputs_helper"
require_relative "assets/utxo"
module ZenWallet
  module Bitcoin
    class InputsHelperTest < Minitest::Test
      # def test_prepare

      def test_collect
        # Select singular within DUST_CHANGE
        res = InputsHelper.collect(UTXO, 9_000_000)
        assert_equal 1, res.length
        assert_equal 9_000_999, res[0].amount
        # Prefer collect small
        res = InputsHelper.collect(UTXO, 23_000_000)
        assert_equal 2, res.length
        # binding.pry
        assert_equal [19_000_000, 9_000_999], res.map(&:amount)
        # Collect single big
        res = InputsHelper.collect(UTXO, 249_897_000)
        assert_equal 1, res.length
        assert_equal 250_453_000, res[0].amount
      end

      def test_select
        # Prefer confirmed
        res = InputsHelper.select(UTXO, 54_000_000)
        assert res.all? { |u| u.confirmations.positive? }
        # select unconfirmed also
        res = InputsHelper.select(UTXO, 154_000_000)
        assert res.map(&:amount).reduce(:+) >= 154_000_000
      end

      def test_prepare_inputs
        # Getting keys
        amount = TOTAL_AMOUNT - 10_000
        result = InputsHelper.prepare_inputs(UTXO, amount) do |addresses|
          addresses.map do |addr|
            OpenStruct.new(address: addr, key: "STUB:#{addr}")
          end
        end
        assert_equal 6, result.inputs.length
        assert_equal 10_000, result.change
        result.inputs.each do |input|
          assert_equal "STUB:#{input.utxo.address}", input.key
        end
        # Hiding DUST_CHANGE
        res = InputsHelper.prepare_inputs(UTXO, 9_000_000) do |addresses|
          addresses.map { |a| OpenStruct.new(address: a, key: "key") }
        end
        sum = res.inputs.map(&:utxo).map(&:amount).reduce(:+)
        assert_equal 999, sum - 9_000_000
        assert_equal 0, res.change
      end
    end
  end
end
