# frozen_string_literal: true
require "dry-monads"
require "inflecto"
require "money-tree"
require "sequel"
require "rake"
require_relative "utils"
require_relative "persistence/store"

module ZenWallet
  # Stores wallets and addresses in database
  module Persistence
    def self.connect(db)
      Instance.new(connect_from_any(db))
    end

    def self.migrate(db)
      Sequel.extension :migration
      sequel = connect_from_any(db)
      Sequel::Migrator.run(sequel, "#{__dir__}/persistence/migrations")
    end

    private_class_method def self.connect_from_any(db)
      db.is_a?(Sequel::Database) ? db : Sequel.connect(db)
    end

    # main store instance
    class Instance
      I = Inflecto
      def initialize(sequel)
        @sequel = sequel
        find_stores.each do |table, klass|
          define_singleton_method(table) { klass.new(@sequel[table]) }
        end
      end

      private

      def find_stores
        pattern = "#{__dir__}/persistence/*.rb"
        # Table with same name as file
        tables = Rake::FileList.new(pattern).pathmap("%n").exclude("store")
        pairs = tables.map do |table|
          require_relative "persistence/#{table}"
          [table.to_sym, ZenWallet::Persistence.const_get(I.camelize(table))]
        end
        pairs = pairs.select { |pair| pair[1] < ZenWallet::Persistence::Store }
        Hash[pairs]
      end
    end
  end
end
