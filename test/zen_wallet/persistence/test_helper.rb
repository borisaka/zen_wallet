require "test_helper"
require "zen_wallet/hd"
require "zen_wallet/persistence"
# ZenWallet::Persistence
module RepoMixin
  def before_setup
    @container = ZenWallet::Persistence.container
    @sequel = @container.resolve("sequel")
  end
end
