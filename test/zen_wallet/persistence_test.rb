# frozen_string_literal: true
require "test_helper"
require "zen_wallet/persistence"
# require "zen_wallet/wallet"
# require "zen_wallet/account"
require "sequel"
require "ostruct"
module ZenWallet
  class PersistenceTest < Minitest::Test
    def test_connect
      assert_instance_of Persistence::Instance, Persistence.connect("sqlite:")
    end

    def test_migrate!
      sequel = Sequel.sqlite
      Persistence.migrate(sequel)
      assert_equal [:schema_info, :wallets, :accounts, :chain_addresses],
                   sequel.tables
    end

    def test_connect_from_any
      # From Sequel::Database
      assert_kind_of Sequel::Database,
                     Persistence.send(:connect_from_any, Sequel.sqlite)
      # From connection_string
      assert_kind_of Sequel::Database,
                     Persistence.send(:connect_from_any, "sqlite:")
    end
  #   def setup
  #     @sequel = Sequel.sqlite
  #     ZenWallet::Store.setup(@sequel)
  #     @store = ZenWallet::Store.new(@sequel)
  #     @w_attrs = { id: "id", encrypted_seed: "encrypted_seed",
  #                  salt: "salt", public_seed: "pubkey" }
  #     @a_attrs = { id: "main", wallet_id: "id",
  #                  private_key: "private_key", public_key: "public_key",
  #                  address: "address", order: 1 }
  #     @wallet = Wallet.new(@store, **@w_attrs)
  #     @account = Account.new(@wallet, **@a_attrs)
  #   end
  #

  #   def test_next_account_index
  #     @sequel[:wallets].insert(@w_attrs)
  #     # if zero
  #     assert_equal 0, @store.next_account_index("id")
  #     # if many
  #     accounts_count = rand(100)
  #     accounts_count.times do |i|
  #       @sequel[:accounts].insert(@a_attrs.merge(id: "id_#{i}", order: i + 1))
  #     end
  #     assert_equal accounts_count + 1, @store.next_account_index("id")
  #   end
  #

  #   def test_set_account_private_key
  #     @sequel[:wallets].insert(@w_attrs)
  #     @sequel[:accounts].insert(@a_attrs)
  #     @store.set_account_private_key("id", "main", "new_privkey")
  #     assert_equal "new_privkey",
  #                  @store.load_account("id", "main")[:private_key]
  #   end
  end
end
