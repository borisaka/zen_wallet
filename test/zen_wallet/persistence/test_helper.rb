# frozen_string_literal: true
require "test_helper"
require "zen_wallet/hd/wallet"
require "zen_wallet/service"
module PersistenceMixin
  def before_setup
    super
    @container = ZenWallet::Service.container do |cfg|
      logger = Logger.new(STDOUT)
      logger.level = Logger::INFO
      cfg.logger = logger
    end
    @sequel = @container.resolve("sequel")
    @dataset = @sequel[table_name]
  end

  private

  def table_name
    full_name = self.class.name.sub("Test", "").sub("Repo", "")
    base_name = Inflecto.demodulize(full_name)
    Inflecto.underscore(Inflecto.pluralize(base_name)).to_sym
  end

  def relation(name = table_name)
    @container.resolve("rom").relation(name)
  end
end

class RelationTest < Minitest::Test
  include PersistenceMixin

  def setup
    super
    @relation = relation # @container.resolve("rom").relation(table_name)
  end
end

class RepoTest < Minitest::Test
  include PersistenceMixin

  def setup
    super
    @repo = @container.resolve(repo_name)
  end

  private

  def repo_name
    Inflecto.singularize(table_name) + "_repo"
  end
end

module ZenWallet
  module TxAccountTestMixin
    def test_tx_account_amount
      wid = WalletConstants::ID
      bid = AccConstants::Balance::ID
      pid = AccConstants::Payments::ID
      assert_equal 0, @repo.tx_account_amount(@attrs[:txid], wid, bid)
      @dataset.update(wallet_id:  wid, account_id: bid)
      @dataset.insert(@attrs.merge(wallet_id: wid, account_id: pid, amount: 30_000, index: 1).merge(custom_args))
      @dataset.insert(@attrs.merge(wallet_id: wid, account_id: bid, amount: 40_000, index: 2).merge(custom_args))
      assert_equal 50_000, @repo.tx_account_amount(@attrs[:txid], wid, bid)
    end

    private

    def custom_args
      {}
    end
  end
end
