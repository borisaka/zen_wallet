# frozen_string_literal: true
require "rethinkdb"
require_relative "store/base"
include RethinkDB::Shortcuts
module ZenWallet
  module HD
    # Simple rethinkdb store
    # TODO: refactor to rom-rethinkdv
    class Store < StoreBase
      class Migrator
        def initialize(conn)
          @conn = conn
        end

        def create_table_unless_exists(name)
          r.table_create(name).run(@conn) unless @tables.include?(name)
          # r.table(name).index_create("wallet_and_account") do |doc|
          create_index_unless_exists(name, "wallet_and_account") do |doc|
            [doc["wallet"], doc["account"]]
          end
        end

        def create_index_unless_exists(table, name, &blk)
          indexes = r.table(table).index_list.run(@conn)
          return if indexes.include?(name)
          r.table(table).index_create(name, &blk).run(@conn)
        end

        def migrate
          db = @conn.default_db
          r.db_create(db).run(@conn) unless r.db_list.run(@conn).include?(db)
          @tables = r.table_list.run(@conn)
          # create_table_unless_exists("blocks")
          create_table_unless_exists("accounts")
          create_table_unless_exists("transactions")
          create_table_unless_exists("utxo")
          # create_index_unless_exists("blocks", "time")
          create_index_unless_exists("transactions", "watx") do |doc|
            [doc["wallet"], doc["account"], doc["txid"]]
          end
          create_index_unless_exists("transactions", "txid")
          create_index_unless_exists("utxo", "txid")
          create_index_unless_exists("utxo", "txid_and_n") do |doc|
            [doc["txid"], doc["n"]]
          end
          r.table("transactions").index_wait.run(@conn)
          r.table("utxo").index_wait.run(@conn)
        end
      end
      require_relative "store/transactions"
      require_relative "store/utxo"

      def balance
        accounts.get_all([wid, idx], index: "wallet_and_account")
                .limit(1).run(@conn).first&.fetch("balance")
      end

      def store_balance(balance)
        accounts.insert([{ wallet: wid,
                           account: idx,
                           balance: balance,
                           time_stamp: Time.now }],
                        conflict: :update).run(@conn)
      end

      def transactions
        @transactions ||= Transactions.new(@conn, @account)
      end

      def utxo
        @utxo ||= Utxo.new(@conn, @account)
      end

      def table
        r.table("accounts")
      end

      private

      def accounts
        r.table("accounts")
      end
    end
  end
end
