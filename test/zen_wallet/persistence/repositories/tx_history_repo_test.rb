require_relative "../test_helper"
require "mixins/address"
require "zen_wallet/persistence/repositories/tx_history_repo"
module ZenWallet
  module Peristence
    class TxHistoryRepoTest < RepoTest
      include AddressMixin 
      def setup
        super
        @sequel[:wallets].insert(@wallet_attrs)
        @sequel[:accounts].insert(@acc_balance_attrs)
        @wid = WalletConstants::ID
        @aid = AccConstants::Balance::ID
        @sequel[:transactions].insert(txid: "TX0")
        @attrs = { wallet_id: @wid, account_id: @aid, txid: "TX0", balance: nil, amount: nil }
      end

      def test_create
        @repo.create(@attrs)
        assert_equal @attrs, @dataset.first
      end

      def test_detect
        @dataset.insert(@attrs)
        assert_equal @attrs, @repo.detect("TX0", @wid, @aid).to_h
      end

      def test_account_balance
        assert_equal 0, @repo.account_balance(@wid, @aid)
        @sequel[:transactions].update(block_height: 2, block_position: 5)
        @dataset.insert(@attrs.merge(balance: 10))
        @sequel[:transactions].insert(txid: "TX1", block_height: 2, block_position: 3)
        @dataset.insert(@attrs.merge(txid: "TX1", balance: 20))
        assert_equal 10, @repo.account_balance(@wid, @aid)
      end

     # def test_clean
     #   @dataset.insert(@attrs)
     #   @sequel[:accounts].insert(@acc_payments_attrs)
     #   @dataset.insert(@attrs.merge(account_id: AccConstants::Payments::ID))
     #   assert_equal 2, @dataset.count
     #   @repo.clean(@wid, @aid)
     #   assert_equal 1, @dataset.count
     #   assert_equal AccConstants::Payments::ID, @dataset.first[:account_id]
      # end

      private

      def repo_name
        "tx_history_repo"
      end

      def table_name
        :tx_history
      end
    end
  end
end
