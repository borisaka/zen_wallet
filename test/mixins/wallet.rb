# frozen_string_literal: true
module ZenWallet
  module WalletConstants
    ID = "id"
    RANDOM_SEED = "rand"
    XPRV = "xprv9s21ZrQH143K3GNRYA9AUQWtkTiBT5oPuo1krix1SMEUp6n1az4MB5J4V8y"\
           "5x1zEm8eyviwa544cJrdyX9ASkTWNGMUzDdo6s5KDt3XLjgP"
    XPUB = "xpub661MyMwAqRbcFkSteBgAqYTdJVYfrYXFH1wMf7MczgmTgu7A8XNbiscYLP"\
            "YJ7esLiLiRURjtrJVZeqGc3o9CKad2zrA8CzPoR9wCPAra73R"
    SALT = "salt"
    PASSPHRASE = ""
    SECURED_XPRV = "w2QvPux444B2FMEXr8yAaSU8w6yaFISClukNwOY7n57GDrA0RSBOkpYg"\
                   "l332\niEOaHvAC748ZZqmqoRGCeYCjOatjLDzRCzONXaIwkeOgxsYKqtI"\
                   "QBmm61/Xu\nYWNlaun15jgv36sL3FtZILS2+bjOMw==\n"
    # Changed attrs
    CH_PASSPHRASE = "ch_passphrace"
    CH_SALT = "ch_salt"
    CH_SECURED_XPRV = "1VYJl3etvTO5/q59K8PyCAVkQ4mRsjR8xHJ8TE/tv+8JGSVuYwKP/F3"\
                      "8uZ/p\nonGkCbXaHHJHYJS1VUPeLpYSiIRULMHLPK9jMSLEuWHhEZom"\
                      "wn+HeXo5ffz8\nViwKVRI1/18l964Pg/UUH4ulfxO+Sw==\n"
  end
  module WalletAttrsMixin
    def before_setup
      super
      @wallet_attrs = {
        id: WalletConstants::ID,
        secured_xprv: WalletConstants::SECURED_XPRV,
        xpub: WalletConstants::XPUB,
        salt: WalletConstants::SALT
      }
      @wallet_ch_attrs =
        @wallet_attrs.merge(secured_xprv: WalletConstants::CH_SECURED_XPRV,
                            salt: WalletConstants::CH_SALT)
    end
  end

  module WalletModelMixin
    include WalletAttrsMixin
    def before_setup
      super
      @wallet_model = HD::Models::Wallet.new(@wallet_attrs)
      @wallet_ch_model = HD::Models::Wallet.new(@wallet_ch_attrs)
    end
  end
end
