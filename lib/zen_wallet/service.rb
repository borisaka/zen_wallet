# frozen_string_literal: true
require "dry-configurable"
require "dry-container"
require "sequel"
require "rom"
require "rom-repository"
require "btcruby"
require "logger"
require_relative "persistence/repositories/wallet_repo"
require_relative "persistence/repositories/account_repo"
require_relative "persistence/repositories/address_repo"
require_relative "hd/store"

module ZenWallet
  # Stores wallets and addresses in database
  module Service
    class Instance
      extend Dry::Configurable
      setting :db, "sqlite:/"
      setting :automigrate, true
      setting :bitcoin_network, :mainnet
      setting :rethinkdb, db: "wallet_db"
      setting :logger, Logger.new(STDOUT)
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
        register :logger, config.logger
        sequel = Sequel.connect(config.db)
        register :sequel, sequel
        Migrator.new(sequel).run
        rom_config = ROM::Configuration.new(:sql, sequel)
        rom_config.auto_registration("#{__dir__}/persistence",
                                     namespace: "ZenWallet::Persistence")
        rom_container = ROM.container(rom_config) do |conf|
          conf.gateways[:default].use_logger(resolve("logger"))
        end
        register :rom, rom_container
        register_repos
        register :bitcoin_network, BTC::Network.send(config.bitcoin_network)
        rethink = RethinkDB::Connection.new(config.rethinkdb)
        register :rethinkdb, rethink
        HD::Store::Migrator.new(rethink).migrate
      end

      def register_repos
        register(:wallet_repo, Persistence::WalletRepo.new(resolve(:rom)))
        register(:account_repo, Persistence::AccountRepo.new(resolve(:rom)))
        register(:address_repo, Persistence::AddressRepo.new(resolve(:rom)))
      end
    end

    def self.container(&blk)
      instance = Class.new(Instance)
      instance.configure(&blk) if block_given?
      Container.new(instance.config)
    end
  end
end
