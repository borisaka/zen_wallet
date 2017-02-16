# frozen_string_literal: true
require "rethinkdb"
include RethinkDB::Shortcuts
module ZenWallet
   # Simple store for UTXO
  class Store
    def initialize(rethink, migrate: false)
      @conn = rethink
      db_migrate! if migrate
    end

    def balance(account)
      accounts.get(acc_id(account)).run(@conn)&.fetch("balance")
      # ["balance"]
    end

    def store_balance(account, balance)
      accounts.insert([{ id: acc_id(account),
                         balance: balance,
                         time_stamp: Time.now.to_i }],
                      conflict: :update).run(@conn)
    end

    private

    def acc_id(account)
      format("%s.%s", account.wallet_id, account.index)
    end

    def accounts
      r.table("accounts")
    end

    def db_migrate!
      db = @conn.default_db
      r.db_create(db).run(@conn) unless r.db_list.run(@conn).include?(db)
      tables = r.table_list.run(@conn)
      r.table_create(:accounts).run(@conn) unless tables.include?("accounts")
      # r.table_create(:lst_blocks).run(m_conn) unless tables.include?("lst_blocks")
      # r.table_create(:addresses) unless tables.include?("addresses")
      # r.table_create(:txs) unless tables.include?("txs")
      # r.table_create(:utxo) unless tables.include?("utxo")
    end
  end
end
