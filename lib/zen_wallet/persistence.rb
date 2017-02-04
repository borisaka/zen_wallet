# frozen_string_literal: true
require "dry-configurable"
require "dry-container"
require "sequel"
require "rom"
require "rom-repository"
# require "zen_wallet/persistence/relations/wallets"
require_relative "persistence/repositories/wallet_repo"

module ZenWallet
  # Stores wallets and addresses in database
  module Persistence
    class Instance
      extend Dry::Configurable
      setting :db, "sqlite::memory"
      setting :automigrate, true
    end

    class Migrator
      def initialize(sequel)
        @sequel = sequel
      end

      def run
        Sequel.extension :migration
        Sequel::Migrator.run(@sequel, "#{__dir__}/persistence/migrations")
      end
    end

    class Container
      include Dry::Container::Mixin

      def initialize(config)
        sequel = Sequel.connect(config.db)
        register :sequel, sequel
        Migrator.new(sequel).run
        rom_config = ROM::Configuration.new(:sql, sequel)
        rom_config.auto_registration("#{__dir__}/persistence",
                                     namespace: "ZenWallet::Persistence")
        register :rom, ROM.container(rom_config)
        register(:wallet_repo, WalletRepo.new(resolve(:rom)))
      end
    end

    def self.container(&blk)
      instance = Class.new(Instance)
      instance.configure(&blk) if block_given?
      Container.new(instance.config)
    end
  end
end
