# frozen_string_literal: true
require "test_helper"
require "zen_wallet/crypto"
module ZenWallet
  class CryptoTest < Minitest::Test
    def setup
      @seed = "My text"
      @passphrase = "123"
      @encrypted64 = "0QAtxqZGsoGA56rHEWFB2Q==\n"
    end

    def test_encrypt
      assert_equal @encrypted64, Crypto.encrypt(@seed, @passphrase, "1")
    end

    def test_decrypt
      assert_equal @seed, Crypto.decrypt(@encrypted64, @passphrase, "1")
    end
  end
end
