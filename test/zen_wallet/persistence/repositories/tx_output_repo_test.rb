require_relative "../test_helper"
require "mixins/account"
require "zen_wallet/persistence/repositories/tx_output_repo"
module ZenWallet
  module Persistence
    class TxOutputRepoTest < RepoTest
      include AccountMixin
      include TxAccountTestMixin
      def setup
        super
        [{ txid: "0" }, { txid: "1" }].each { |attrs|  @sequel[:transactions].insert(attrs) }
        @attrs = { txid: "0", index: 0, address: "1234", amount: 10_000, script: "12345", wallet_id: nil, account_id: nil }
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

      def test_detect
        assert_equal @attrs, @repo.detect("0", 0).to_h
      end

      def test_by_tx
        assert_equal [@attrs], @repo.by_tx("0").map(&:to_h)
      end

      def test_by_address
        assert_equal [@attrs], @repo.by_address("1234").map(&:to_h)
      end

      def test_utxo
        wid, aid = [WalletConstants::ID, AccConstants::Balance::ID]
        all_attrs = [@attrs, *[[1, 21_000], [2, 32_000]].map { |add| @attrs.merge(index: add[0], amount: add[1]) }]
        all_attrs[1..-1].each { |attrs| @dataset.insert(attrs) }
        all_attrs.map! { |attrs| attrs.merge(wallet_id: wid, account_id: aid) }
        @dataset.update(wallet_id: wid, account_id: aid)
        @dataset.insert(@attrs.merge(wallet_id: wid, account_id: AccConstants::Payments::ID, index: 3))
        @sequel[:tx_inputs].insert(txid: "1", index: 0, prev_txid: "0", prev_index: 1, amount: 21_000, address: "1234")
        assert_equal [all_attrs[0], all_attrs[2]], @repo.utxo(wid, aid).map(&:to_h)
      end

    end
  end
end
