# frozen_string_literal: true
require "base64"
module ZenWallet
  # Basic cryptographic function to store wallet
  module Crypto
    module_function

    def encrypt(text, passphrase, salt)
      cipher = OpenSSL::Cipher.new("AES-128-CBC")
      cipher.encrypt
      cipher.key = OpenSSL::PKCS5
                   .pbkdf2_hmac_sha1(passphrase, salt, 20_000, 16)
      cipher.iv = OpenSSL::PKCS5.pbkdf2_hmac_sha1(salt, "", 20_000, 16)
      encrypted = cipher.update(text) + cipher.final
      Base64.encode64(encrypted)
    end

    def decrypt(encrypted64, passphrase, salt)
      encrypted_text = Base64.decode64(encrypted64)
      decipher = OpenSSL::Cipher::AES.new(128, :CBC)
      decipher.decrypt
      decipher.key = OpenSSL::PKCS5
                     .pbkdf2_hmac_sha1(passphrase, salt, 20_000, 16)
      decipher.iv = OpenSSL::PKCS5.pbkdf2_hmac_sha1(salt, "", 20_000, 16)
      decipher.update(encrypted_text) + decipher.final
    end
  end
end
