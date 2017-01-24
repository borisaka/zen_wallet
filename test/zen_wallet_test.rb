require "test_helper"
require "zen_wallet"
class ZenWalletTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ZenWallet::VERSION
  end
end
