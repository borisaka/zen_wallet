# frozen_string_literal: true
require "test_helper"
require "zen_wallet/hd/wallet"
require "zen_wallet/service"
module PersistenceMixin
  def before_setup
    super
    @container = ZenWallet::Service.container
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
