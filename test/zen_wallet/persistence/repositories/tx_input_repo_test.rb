require_relative "../test_helper"
require "mixins/account"
require "zen_wallet/persistence/repositories/tx_input_repo"
module ZenWallet
  module Persistence
    class TxInputRepoTest < RepoTest
      include AccountMixin
      include TxAccountTestMixin
      def setup
        super
        [{ txid: "0" }, { txid: "1" }].each { |attrs|  @sequel[:transactions].insert(attrs) }
        @out_attrs = { txid: "0", index: 0, address: "1234", amount: 10_000, script: "12345" }
        @sequel[:tx_outputs].insert(@out_attrs)
        @attrs = { txid: "1", 
                   index: 0, 
                   prev_txid: "0", 
                   prev_index: 0, 
                   amount: 10_000,
                   address: "1234",
                   wallet_id: nil,
                   account_id: nil }
        @dataset.insert(@attrs)
        @sequel[:wallets].insert(@wallet_attrs)
        @sequel[:accounts].insert(@acc_balance_attrs)
        @sequel[:accounts].insert(@acc_payments_attrs)
      end

      def test_create
        @dataset.delete
        @repo.create(@attrs)
        assert_equal @attrs, @dataset.first
      end

      def test_by_tx
        assert_equal [@attrs], @repo.by_tx("1").map(&:to_h)
      end

      #def test_by_source
      #  assert_equal @attrs, @repo.by_source("0", 0).to_h 
      #end
      #
      private

      def custom_args
        @dataset.select{ [(max(index) + 1).as(:index), (max(prev_index) + 1).as(:prev_index)] }.first
      end
    end
  end
end
