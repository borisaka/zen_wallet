# frozen_string_literal: true
require_relative "test_helper"
require "zen_wallet/persistence/chain_addresses"
require "zen_wallet/hd/chain_address"
# require "zen_wallet/instance"
module ZenWallet
  module Persistence
    class ChainAddressesTest < Minitest::Test
      include TestMixin

      def setup
        @ca_attrs = { address: "addr", account_id: "main", change: 0, order: 0,
                      wallet_id: "id", public_key: "ca_public_key",
                      private_key: "ca_private_key" }
        @chain_address = HD::ChainAddress.new(@account, **@ca_attrs)
      end

      def test_persist
        insert_wallet
        insert_account
        assert_equal @ca_attrs, @store.persist(@chain_address)
        assert_equal @ca_attrs, @dataset.first
      end

      def test_lookup
        insert_chain_address
        assert_equal @ca_attrs, @store.lookup("id", "main", 0, 0)
      end

      def test_next_index
        insert_account
        assert_equal 0, @store.next_index("id", "main")
        addresses_count = rand(100)
        addresses_count.times do |i|
          @dataset.insert(@ca_attrs.merge(address: "id_#{i}", order: i + 1))
        end
        assert_equal addresses_count + 1, @store.next_index("id", "main")
      end

      private

      def insert_chain_address
        insert_account
        @dataset.insert(**@ca_attrs)
      end
    end
  end
end
