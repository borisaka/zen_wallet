require_relative "test_helper"
require "zen_wallet/hd/store"
require "mixins/account"
module ZenWallet
  module HD
    class StoreTest < BaseStoreTest
      # def setup
      #   super
      # end

      def test_store_balance
        stamp = Time.now
        attrs = { "wallet" => @wid,
                  "account" => @idx,
                  "balance" => 10_000,
                  "time_stamp" => stamp }
        ch_attrs = attrs.merge("balance" => 9_800, "time_stamp" => stamp + 5)
        Time.stubs(:now).returns(stamp)
        # inserts
        @store.store_balance(10_000)
        # binding.pry
        result = r.table("accounts")
                  .get_all([@wid, @idx], index: "wallet_and_account")
                  .limit(1).run(@conn).first
        assert_equal attrs["balance"], result["balance"]
        assert_equal stamp.to_i, result["time_stamp"].to_i
        # overrides
        Time.stubs(:now).returns(stamp + 5)
        @store.store_balance(9_800)
        result = r.table("accounts").filter(wallet: @wid, account: @idx)
                  .limit(1).run(@conn).first
        assert_equal ch_attrs["balance"], result["balance"]
        assert_equal stamp.to_i + 5, result["time_stamp"].to_i
      end

      def test_balance
        # empty
        assert_nil @store.balance
        attrs = { "wallet" => @wid, "account" => @idx, "balance" => 110_000 }
        r.table(:accounts).insert(attrs).run(@conn)
        assert_equal @store.balance, 110_000
      end

      # def test_store_tx
      #
      #   assert_equal
      # end

      # def test_load_txs
      #   stamps = [Time.now - 40, Time.now, Time.now + 40]
      #   assert_empty @store.load_txs(@account)
      #   stamps.each do |stamp|
      #     r.table("txs").insert(wallet: @account.wallet_id,
      #                           account: @account.id,
      #                           time: stamp).run(@conn)
      #   end
      #   assert_equal stamps.map(&:to_i).reverse,
      #                @store.load_txs(@account).map { |i| i["time"].to_i }
      # end

      def test_migrate
        tables = r.table_list.run(@conn)
        assert tables.sort == %w(accounts transactions utxo)
      end

      # def test_update_utxo_from_txs
      #   # initial
      #   txs = [{ account: @account.id, wallet: @account.wallet_id, txid: "0",
      #            vout: "1" }]
      # end

      # def teardown
      #   r.db_drop(@db_name).run(@conn)
      #   @conn.close(noreply_wait: true)
      # end
      #
      # private

    end
  end
end
