# frozen_string_literal: true
require "test_helper"
require "zen_wallet/utils"
module ZenWallet
  class UtilsTest < Minitest::Test
    def setup
      @seed = "My text"
      @passphrase = "123"
      @encrypted64 = "0QAtxqZGsoGA56rHEWFB2Q==\n"
    end

    def test_encrypt
      assert_equal @encrypted64, Utils.encrypt(@seed, @passphrase, "1")
    end

    def test_decrypt
      assert_equal @seed, Utils.decrypt(@encrypted64, @passphrase, "1")
    end
  end
end
