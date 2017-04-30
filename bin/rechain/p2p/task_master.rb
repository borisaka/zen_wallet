require "rethinkdb"
require "btcruby"
require "zen_wallet/rechain/block_store"
require_relative "headers_handler"
require_relative "connection"
module ZenWallet
  module P2P
    class TaskMaster
      def initialize
        container = Dry::Container.new
        rethink = RethinkDB::Connection.new(db: "wallet_db")
        container.register("rechain.block_store", Rechain::BlockStore.new(rethink))
        container.register("task_master", self)
        container.register("bitcoin_network", BTC::Network.testnet)
        container.register("logger", Logger.new(STDOUT))
        @headers_handler = HeadersHandler.new(container)
        container.register("headers_handler", @headers_handler)
        @container = container
        # parser = Parser.new(handlers_container)
        @exec_pool = EM::Pool.new
        @exec_pool.on_error do |conn|
          conn.close_connection
          @exec_pool.remove conn
          @exec_pool.add Connection.connect_random_from_dns(@container)
        end
        @tasks = Concurrent::Array.new
      end

      def append(&blk)
        @tasks << blk
      end

      def work
        @exec_pool.add Connection.connect_random_from_dns(@container) if @exec_pool.contents.empty?
        if @tasks.empty?
          @headers_handler.fetch_locators.callback do |locators|
            @tasks << proc { |conn| conn.query_headers(locators) }
          end
        else
          @exec_pool.perform(@tasks.pop)
        end
      ensure
        EM.add_timer(3) { work }
      end

    end
  end
end
