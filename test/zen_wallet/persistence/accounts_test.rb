require_relative "test_helper"
require "zen_wallet/persistence/accounts"
module ZenWallet
  module Persistence
    class AccountsTest < Minitest::Test
      include TestMixin

      def test_persist
        insert_wallet
        assert_equal @a_attrs, @store.persist(@account)
        assert_equal @a_attrs, @dataset.first
      end

      def test_lookup
        insert_account
        assert_equal @a_attrs, @store.lookup("id", "main")
      end

      def test_by_wallet
        insert_wallet
        to_insert = Array.new(10) do |i|
          @a_attrs.merge(id: "id_#{i}", order: i + 1, address: "a_#{i}")
        end
        @dataset.import(to_insert.first.keys, to_insert.map(&:values))
        # All
        assert_equal to_insert, @store.by_wallet("id")
        # Filtered
        assert_equal 1, @store.by_wallet("id", address: "a_2").size
      end

      def test_next_index
        insert_wallet
        assert_equal 0, @store.next_index("id")
        accounts_count = rand(100)
        accounts_count.times do |i|
          @dataset.insert(@a_attrs.merge(id: "id_#{i}", order: i + 1))
        end
        assert_equal accounts_count + 1, @store.next_index("id")
      end

      def test_set_private_key
        insert_account
        @store.set_private_key("id", "main", "new_privkey")
        assert_equal "new_privkey",
                     @dataset.where(id: "main").first[:private_key]
      end
    end
  end
end
