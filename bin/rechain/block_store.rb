# frozen_string_literal: true
require "rethinkdb"
module ZenWallet
  module Rechain
    class BlockStore
      include RethinkDB::Shortcuts

      def initialize(conn)
        @conn = conn || r.connect
      end

      def append(headers)
        puts "APPEND: #{headers}"
        rel.insert(headers).run(@conn)
      end

      def detect(id)
        rel.get(id).run(@conn)
      end

      # Little synchronyous operation
      def empty?
        rel.is_empty.run(@conn)
      end

      def last_ids(limit)
        sel = rel.order_by(index: r.desc(:time))
                 .limit(limit)
                 .map { |blk| blk[:id] }.run(@conn).to_a
      end

      def last
        rel.order_by(index: r.desc(:time)).limit(1).run(@conn)
      end

      private

      def rel
        r.table("blocks")
      end
    end
  end
end
