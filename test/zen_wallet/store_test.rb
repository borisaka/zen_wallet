# frozen_string_literal: true
require "test_helper"
require "zen_wallet/store"
require "zen_wallet/wallet"
require "zen_wallet/account"
require "sequel"
require "ostruct"
module ZenWallet
  class StoreTest < Minitest::Test
    def setup
      @sequel = Sequel.sqlite
      ZenWallet::Store.setup(@sequel)
      @store = ZenWallet::Store.new(@sequel)
      @w_attrs = { id: "id", encrypted_seed: "encrypted_seed",
                   salt: "salt", public_seed: "pubkey" }
      @a_attrs = { id: "main", wallet_id: "id",
                   private_key: "private_key", public_key: "public_key",
                   address: "address", order: 1 }
      @wallet = Wallet.new(@store, **@w_attrs)
      @account = Account.new(@wallet, **@a_attrs)
    end

    def test_setup
      assert_equal [:schema_info, :wallets, :accounts], @sequel.tables
    end

    def test_create_wallet
      ds = @sequel[:wallets]
      attrs = @store.create_wallet(@wallet)
      assert_equal @w_attrs, attrs
      assert_equal @w_attrs, ds.first
    end

    def test_load_wallet
      ds = @sequel[:wallets]
      ds.insert(**@w_attrs)
      assert_equal @w_attrs, @store.load_wallet("id")
    end

    def test_create_account
      @sequel[:wallets].insert(@w_attrs)
      ds = @sequel[:accounts]
      @store.expects(:next_account_index).with("id").returns(1)
      attrs = @store.create_account(@account)
      assert_equal @a_attrs, attrs
      assert_equal @a_attrs, ds.first
    end

    def test_next_account_index
      @sequel[:wallets].insert(@w_attrs)
      # if zero
      assert_equal 1, @store.next_account_index("id")
      # if many
      accounts_count = rand(100)
      accounts_count.times do |i|
        @sequel[:accounts].insert(@a_attrs.merge(id: "id_#{i}", order: i))
      end
      assert_equal accounts_count, @store.next_account_index("id")
    end

    def test_load_account
      @sequel[:wallets].insert(@w_attrs)
      @sequel[:accounts].insert(@a_attrs)
      assert_equal @a_attrs, @store.load_account("id", "main")
    end

    def test_set_account_private_key
      @sequel[:wallets].insert(@w_attrs)
      @sequel[:accounts].insert(@a_attrs)
      @store.set_account_private_key("id", "main", "new_privkey")
      assert_equal "new_privkey",
                   @store.load_account("id", "main")[:private_key]
    end
  end
end
