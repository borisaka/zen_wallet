# frozen_string_literal: true
LIB_ROOT = File.expand_path(File.join("..", "..", "lib"), __FILE__)
$LOAD_PATH.unshift LIB_ROOT
require "dry-container"
require "minitest/autorun"
require "mocha/mini_test"
require "pry-byebug"
require "pry"
require "btcruby"
require "zen_wallet/models"
module ZenWalletTestMixin
  def before_setup
    super
  end
end

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
    CH_PASSPHRACE = "ch_passphrace"
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
      @wallet_model = Models::Wallet.new(@wallet_attrs)
      @wallet_ch_model = Models::Wallet.new(@wallet_ch_attrs)
    end
  end

  module AccConstants
    module Balance
      WALLET_ID = WalletConstants::ID
      ID = "balance"
      INDEX = 0
      XPRV = nil
      XPUB = "xpub6CkgFunC9aHPkmGz68kutK7YKUShM2utoWqpbSBhW24M9jKby5VVUyZpg"\
              "4DdWmxh5TVHjmzZoBP7FbyJMjj8hV2M3aihXFFvHJdFBQHc1Ds"
    end

    module Payments
      WALLET_ID = WalletConstants::ID
      ID = "payments"
      INDEX = 1
      XPRV = nil
      CH_XPRV = "xprv9ymKrQFJKCj6bHB6QFwxx7x6okFQNrhJbrcQfAtSMzAXaneEw2qRzsjts"\
             "yUUz64p963iGvxPdZpm3ZZwkEiq6ZSXFDeUJTXTmQrLcqLJJDW"
      XPUB = "xpub6CkgFunC9aHPomFZWHUyKFtqMn5tnKR9y5Y1TZJ3vKhWTayPUa9gYg4NjDm"\
             "1DxM9ZyVkqJo1tpRsDTQHFyPq2JEiryC9bSYvoYjhtQ8CURz"
    end
  end

  module AccAttrsMixin
    def before_setup
      super
      @acc_balance_attrs = {
        id: AccConstants::Balance::ID,
        wallet_id: AccConstants::Balance::WALLET_ID,
        index: AccConstants::Balance::INDEX,
        xprv: AccConstants::Balance::XPRV,
        xpub: AccConstants::Balance::XPUB
      }
      @acc_payments_attrs = {
        id: AccConstants::Payments::ID,
        wallet_id: AccConstants::Payments::WALLET_ID,
        index: AccConstants::Payments::INDEX,
        xprv: AccConstants::Payments::XPRV,
        xpub: AccConstants::Payments::XPUB
      }
      @acc_payments_ch_attrs = @acc_payments_attrs
                               .merge(xprv: AccConstants::Payments::CH_XPRV)
    end
  end

  module AccModelMixin
    include AccAttrsMixin
    def before_setup
      super
      @acc_balance_model = Models::Account.new(@acc_balance_attrs)
      @acc_payments_model = Models::Account.new(@acc_payments_attrs)
      @acc_payments_ch_model = Models::Account.new(@acc_payments_ch_attrs)
    end
  end

  module AddressMixin
    def before_setup
      super
      keychain = BTC::Keychain
                 .new(xpub: AccConstants::Balance::XPUB)
                 .bip44_external_keychain
      @addresses_attrs = (0..19).map do |i|
        {
          wallet_id: WalletConstants::ID,
          account_index: AccConstants::Balance::INDEX,
          change: 0,
          index: i,
          address: keychain.derived_keychain(i).key.address.to_s,
          has_txs: false
        }
      end
      @addresses_models = @addresses_attrs.map do |attrs|
        Models::Address.new(attrs)
      end
    end
  end
end
