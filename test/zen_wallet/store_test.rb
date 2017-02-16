require "test_helper"
require "zen_wallet/store"
require "mixins/account"
module ZenWallet
  class StoreTest < Minitest::Test
    include AccountMixin
    include RethinkDB::Shortcuts
    def setup
      @db_name = format("wallet_test_%d", Time.now.to_i)
      @config = { db: @db_name }
      @conn = r.connect(@config)
      @store = Store.new(@conn, migrate: true)
      @account = @acc_balance_model
      @acc_id = format("%s.%s", @account.wallet_id, @account.index)
    end

    def test_store_balance
      stamp = Time.now
      attrs = { "id" => @acc_id, "balance" => 10_000, "time_stamp" => stamp.to_i }
      ch_attrs = attrs.merge("balance" => 9_800, "time_stamp" => stamp.to_i + 5)
      Time.stubs(:now).returns(stamp)
      # inserts
      @store.store_balance(@account, 10_000)
      assert_equal attrs, r.table("accounts").get(@acc_id).run(@conn)
      # overrides
      Time.stubs(:now).returns(stamp + 5)
      @store.store_balance(@account, 9_800)
      assert_equal ch_attrs, r.table("accounts").get(@acc_id).run(@conn)
    end

    def test_balance
      # empty
      assert_nil  @store.balance(@account)
      attrs = { "id" => @acc_id, "balance" => 110_000 }
      r.table(:accounts).insert(attrs).run(@conn)
      assert_equal @store.balance(@account), 110_000
    end

    def test_migrate
      tables = r.table_list.run(@conn)
      assert tables.sort == %w(accounts)
    end

    def teardown
      r.db_drop(@db_name).run(@conn)
      @conn.close(noreply_wait: true)
    end

    private

  end
end
