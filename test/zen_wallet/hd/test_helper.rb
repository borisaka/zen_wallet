# frozen_string_literal: true
require "test_helper"
require "rethinkdb"
require "mixins/account"
require "zen_wallet/hd/store"
class HDTest < Minitest::Test
  def setup
    super
    @container = Dry::Container.new
    @network = BTC::Network.mainnet
    @container.register("bitcoin_network", @network)
  end
end
module ZenWallet
  module HD
    class BaseStoreTest < Minitest::Test
      include RethinkDB::Shortcuts
      include AccountMixin
      def setup
        @db_name = format("wallet_test_%d", Time.now.to_i)
        @config = { db: @db_name }
        @conn = r.connect(@config)
        Store::Migrator.new(@conn).migrate
        @account = @acc_balance_model
        @store = Store.new(@conn, @account)
        @wid = @account.wallet_id
        @idx = @account.index
      end

      def teardown
        r.db_drop(@db_name).run(@conn)
        @conn.close(noreply_wait: true)
      end
    end
  end
end
