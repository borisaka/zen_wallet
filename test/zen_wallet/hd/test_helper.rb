# frozen_string_literal: true
require "test_helper"
require "rethinkdb"
require "mixins/account"
require "mixins/hash_utils"
require "zen_wallet/hd/store"
require "minitest/hooks"

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
      include HashUtils
      include Minitest::Hooks
      def before_all
        super
        @db_name = format("wallet_test_%d", Time.now.to_i)
        @config = { db: @db_name }
        @conn = r.connect(@config)
        Store::Migrator.new(@conn).migrate
      end

      def setup
        r.table_list
          .foreach { |t| r.table(t).delete }
          .run(@conn)
        @account = @acc_balance_model
        @store = Store.new(@conn, @account)
        @wid = @account.wallet_id
        @idx = @account.index
      end

      def after_all
        super
        r.db_drop(@db_name).run(@conn)
        @conn.close(noreply_wait: true)
      end

      private

      def build_tx(attrs)
        attrs = { txid: SecureRandom.uuid }.merge(attrs)
        defaults = { wallet: @wid,
                     account: @idx,
                     id: "#{@wid}.#{@idx}.#{attrs[:txid]}" }
        defaults.merge(attrs)
      end

      def create_tx(attrs)
        r.table("transactions").insert(build_tx(attrs)).run(@conn)
      end

    end
  end
end
