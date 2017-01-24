require "base64"
module ZenWallet
  module Utils
    module_function

    def build_wallet(passphrase = "")
      salt = SecureRandom.hex(16)
      master = MoneyTree::Master.new
      serialized_seed = master.to_bip32(:private)
      encrypted_seed = Utils.encrypt(serialized_seed, passphrase, salt)
      Wallet.new(encrypted_seed, master.public_key.key, master.chain_code)
    end

    def encrypt(text, passphrase, salt)
      cipher = OpenSSL::Cipher.new("AES-128-CBC")
      cipher.encrypt
      cipher.key = OpenSSL::PKCS5
                   .pbkdf2_hmac_sha1(passphrase, salt, 20_000, 128)
      cipher.iv = OpenSSL::PKCS5.pbkdf2_hmac_sha1(salt, "", 20_000, 32)
      encrypted = cipher.update(text) + cipher.final
      Base64.encode64(encrypted)
    end

    def decrypt(encrypted64, passphrase, salt)
      encrypted_text = Base64.decode64(encrypted64)
      decipher = OpenSSL::Cipher::AES.new(128, :CBC)
      decipher.decrypt
      decipher.key = OpenSSL::PKCS5
                     .pbkdf2_hmac_sha1(passphrase, salt, 20_000, 128)
      decipher.iv = OpenSSL::PKCS5.pbkdf2_hmac_sha1(salt, "", 20_000, 32)
      decipher.update(encrypted_text) + decipher.final
    end
  end
end
