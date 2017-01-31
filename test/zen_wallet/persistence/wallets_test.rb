# frozen_string_literal: true
require_relative "test_helper"
require "zen_wallet/persistence/wallets"
module ZenWallet
  module Persistence
    class WalletsTest < Minitest::Test
      include TestMixin

      def test_persist
        assert_equal @w_attrs, @store.persist(@wallet)
        assert_equal @w_attrs, @dataset.first
      end

      def test_lookup
        insert_wallet
        assert_equal @w_attrs, @store.lookup("id")
      end

      def test_update_encrypted_seed
        insert_wallet
        @store.update_encrypted_seed("id", "overcrypted!", "new_salt")
        new_attrs =
          @w_attrs.merge(encrypted_seed: "overcrypted!", salt: "new_salt")
        assert_equal new_attrs, @dataset.first
      end
    end
  end
end
