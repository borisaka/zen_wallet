# frozen_string_literal: true
require "inflecto"
require "sequel"
require "test_helper"
require "zen_wallet/persistence"
# require "zen_wallet/hd/service"
require "zen_wallet/hd/wallet"
require "zen_wallet/hd/account"
# require "zen_wallet/account"
module ZenWallet
  module Persistence
    module TestMixin
      def before_setup
        super
        setup_db
        setup_store
        # setup_fixtures
        setup_test_data
      end

      private

      def setup_db
        @sequel = Sequel.sqlite
        Sequel.extension :migration
        migrations_dir = "#{LIB_ROOT}/zen_wallet/persistence/migrations"
        Sequel::Migrator.run(@sequel, migrations_dir)
      end

      def setup_store
        store_const = self.class.name.sub("Test", "")
        table = Inflecto.tableize Inflecto.demodulize(store_const)
        @dataset = @sequel[table.to_sym]
        @store = Inflecto.constantize(store_const).new(@dataset)
      end

      # def setup_fixtures
      #   attrs = { id: "id", encrypted_seed: "encrypted_seed",
      #             salt: "salt", public_seed: "pubkey" }
      #   @wallet_fix = Fixture.new(@sequel, ZenWallet::Wallet, **attrs)
      #   attrs = { id: "main", wallet_id: "id",
      #             public_key: "public_key", private_key: nil,
      #             address: "address", order: 1 }
      #   @account_fix = Fixture.new(@sequel, ZenWallet::Account, **attrs)
      #
      # end


      def setup_test_data
        @w_attrs = { id: "id", encrypted_seed: "encrypted_seed",
                     salt: "salt", public_seed: "pubkey" }
        @a_attrs = { id: "main", wallet_id: "id",
                     public_key: "public_key", private_key: nil,
                     address: "address", order: 1 }
        @ca_attrs = {

        }
        @wallet = HD::Wallet.new(@store, **@w_attrs)
        @account = HD::Account.new(@wallet, **@a_attrs)
      end

      def insert_wallet
        @sequel[:wallets].insert(**@w_attrs)
      end

      def insert_account
        insert_wallet if @sequel[:wallets].where(id: @w_attrs[:id]).count.zero?
        @sequel[:accounts].insert(**@a_attrs)
      end
    end

    # module Fixtures
    #   I = Inflecto
    #
    #   def self.table_by_class(klass)
    #     I.tableize(I.demodulize(klass.name))
    #   end
    #
    #   def self.entity_by_table(table)
    #     ZenWallet.const_get I.camelize(I.singularize(table))
    #   end
    #
    #   def self.store_by_table(table)
    #     ZenWallet::Store.const_get(I.camelize(table))
    #   end
    #
    #   def self.pk_from_schema(schema)
    #     schema.detect { |col| col[1][:primary_key] }.first
    #   end
    #
    #   # def self.stores
    #   #   TABLES.map { |table| store_by_table(table) }
    #   # end
    #
    #
    #   class Fake
    #
    #     def self.attrs(**attributes)
    #       @@template_attrs = attributes
    #     end
    #
    #     def self.required(ancestor)
    #       @@ancestor_class = const_get("Fake#{I.camelize(ancestor)}")
    #     end
    #
    #     attr_reader :sequel, :parent, :attrs, :entity,
    #                 :table, :dataset, :store
    #
    #     def initialize(sequel)
    #       @ancestor = @@ancestor_class.new(sequel)
    #       entity_name = I.demodulize(self.class.name).sub("Fake", "")
    #       entity_kls = ZenWallet.const_get(entity_name)
    #       @sequel = sequel
    #       @table = table_by_class(klass)
    #       @dataset = @sequel[@table]
    #       @attrs = @@template_attrs
    #       @store = store_by_table(@table)
    #       entity_args = @parent ? [@store, @parent] : [@store]
    #       @entity = entity_kls.new(*entity_args, **@attrs)
    #     end
    #
    #     def create_record!
    #       @ancestor.create_record!
    #       dataset.insert(**attrs) if lookup_instance.nil?
    #     end
    #
    #     def lookup(**filters)
    #       dataset.where(filters).first
    #     end
    #   end
    #
    #   class FakeWallet < Fake
    #     attrs id: "id", encrypted_seed: "encrypted_seed",
    #           salt: "salt", public_seed: "pubkey"
    #   end
    #
    #   class FakeAccount < Fake
    #     required :wallet
    #
    #     attrs id: "main", wallet_id: "id",
    #           public_key: "public_key", private_key: nil,
    #           address: "address", order: 1
    #   end
    #
    #   # class
    # end
  end
end
