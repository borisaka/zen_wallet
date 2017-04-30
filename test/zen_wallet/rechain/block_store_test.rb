# frozen_string_literal: true
require "test_helper"
require "rethinkdb"
require "mixins/hash_utils"
require "minitest/hooks"
require "zen_wallet/hd/store"
require "zen_wallet/rechain/block_store"
require "zen_wallet/rechain/evolution"
class Time
  def ==(other)
    to_i == other.to_i
  end
end

module ZenWallet
  module Rechain
    class BlockStoreTest < Minitest::Test
      include RethinkDB::Shortcuts
      include HashUtils
      include Minitest::Hooks

      def setup
        r.table_list.foreach { |t| r.table(t).delete }.run(@conn)
        r.table("blocks")
         .insert([{ id: "12d", time: Time.now - 520 },
                  { id: "12ff22d", time: Time.now - 8000 },
                  { id: "12dsd", time: Time.now - 234 },
                  { id: "1dfd2d", time: Time.now - 600 }]).run(@conn)
      end

      def test_detect
        expected = stringify_keys(id: "12d", time: Time.now - 520)
        assert_equal expected, @store.detect("12d")
        assert_nil @store.detect("unexisted")
        # @store.detect("12d").callback do |val|
        #   assert_equal expected, val
        # end
      end

      def test_empty?
        refute @store.empty?
        r.table("blocks").delete.run(@conn)
        assert @store.empty?
      end

      def test_last_ids
        # 9_990_000_000
        blks = Array.new(1000) do
          { id: SecureRandom.hex, time: Time.at(rand(9_990_000_000)) }
        end
        r.table("blocks").insert(blks).run(@conn)
        expected = r.table("blocks").run(@conn)
                       .to_a.sort_by{ |blk| blk["time"] }.reverse[0..499]
        hashes = @store.last_ids(500)
        assert_equal 500, hashes.length
        assert_equal expected.map {|blk| blk["id"]}, hashes
        # @store.last_ids(500).callback do |hashes|
        #   assert_equal 500, hashes.length
        #   assert_equal expected.map {|blk| blk["id"]}, hashes
        # end
      end

      # def test_last
      #   expected = stringify_keys(id: "12dsd", time: Time.now - 234)
      #   @store.last.callback do |blk|
      #     assert_equal expected, blk
      #   end
      #   r.table("blocks").delete.run(@conn)
      #   @store.last.callback { |lst| assert_nil lst }
      # end
      #
      # def test_last_id
      #   @store.last_id.callback do |id|
      #     assert_equal "12dsd", id
      #   end
      #   r.table("blocks").delete.run(@conn)
      #   @store.last_id.callback { |id| assert_nil id }
      # end

      def before_all
        super
        @db_name = format("wallet_test_%d", Time.now.to_i)
        @config = { db: @db_name }
        @conn = r.connect(@config)
        r.db_create(@db_name).run(@conn)
        @conn.use(@db_name)
        ZenWallet::Rechain::Evolution.configure do |cnf|
          cnf.db = @config
        end
        ZenWallet::Rechain::Evolution.transform
        @store = BlockStore.new(@conn)
      end

      def after_all
        super
        r.db_drop(@db_name).run(@conn)
        @conn.close(noreply_wait: true)
      end
    end
  end
end
