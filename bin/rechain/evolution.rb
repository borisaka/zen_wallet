require "rethinkdb"
require "dry-configurable"
module ZenWallet
  module Rechain
    module Evolution
      include RethinkDB::Shortcuts
      extend Dry::Configurable
      setting :db do
        setting :host, "localhost"
        setting :port, 28015
        setting :name, "test"
        setting :user, nil
        setting :password, nil
      end

      def self.transform
        conn = r.connect(config.db.to_h)
        r.table_create("blocks").run(conn)
        r.table("blocks").index_create("time").run(conn)
        r.table("blocks").index_wait.run(conn)
        r.table_create("checkpoints").run(conn)
        # EM.run { r.talbe_create }
      end
    end
  end
end
