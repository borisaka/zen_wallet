# frozen_string_literal: true
require "test_helper"
require "zen_wallet/hd/chainable"
require "zen_wallet/persistence/store"
require "zen_wallet/introspections"
require "sequel"
require "dry-container"
module ZenWallet
  class IntrospectionsTests < Minitest::Test
    class User
      include Introspections::StoreFinder
      def initialize(container)
        @container = container
      end
    end

    def setup
      @store = Object.new
      @container = Dry::Container.new
      @container.register("store.users", @store)
      @user = User.new(@container)
    end

    def test_table
      # class method
      assert_equal :users, User.table
      # instance method
      assert_equal :users, @user.table
    end

    def test_store
      # class method
      assert_equal @store, User.store(@container)
      # instance method
      assert_equal @store, @user.store
    end
  end
end
