require_relative "../test_helper"
require "mixins/tx_data_mixin"

module ZenWallet
  module Persistence
    class TransactionRepoTest < RepoTest
      include TxDataMixin

      def setup
        super
        @sequel[:wallets].insert(@wallet_attrs)
        @sequel[:accounts].insert(@acc_balance_attrs)
        @sequel[:accounts].insert(@acc_payments_attrs)
      end

      def test_create
        @repo.create(@tx_full_attrs)
        assert_equal @tx_attrs, @dataset.first
      end

      def test_detect
        @dataset.insert(@tx_attrs)
        @tx_inputs.each { |i| i.merge!(txid: "1")}
        @tx_outputs.each { |o| o.merge!(txid: "1")}
        @sequel[:tx_inputs].import(@tx_inputs[0].keys, @tx_inputs.map(&:values))
        @sequel[:tx_outputs].import(@tx_outputs[0].keys, @tx_outputs.map(&:values))
        assert_equal @tx_full_attrs, @repo.detect("1").to_h
      end

      def test_update
        @dataset.insert(txid: "2")
        @repo.update("2", @tx_attrs.select { |k| %i(block_time block_position block_height block_id).include?(k) })
        assert_equal @tx_attrs.merge(time: nil, txid: "2"), @dataset.first
      end

      def test_max_block_height
        assert_equal 0, @repo.max_block_height
        @dataset.insert(txid: "0", block_height: 10)
        @dataset.insert(txid: "1", block_height: 18)
        @dataset.insert(txid: "2", block_height: 12)
        assert_equal 18,  @repo.max_block_height
      end
    end
  end
end
