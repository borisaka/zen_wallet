# frozen_string_literal: true
require_relative "wallet"
module ZenWallet
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
    include WalletAttrsMixin
    def before_setup
      super
      attrs_fun = lambda do |cns|
        { id: cns::ID, wallet_id: cns::WALLET_ID, index: cns::INDEX,
          xprv: cns::XPRV, xpub: cns::XPUB }
      end
      @acc_balance_attrs = attrs_fun[AccConstants::Balance]
      @acc_payments_attrs = attrs_fun[AccConstants::Payments]
      @acc_payments_ch_attrs = @acc_payments_attrs
                               .merge(xprv: AccConstants::Payments::CH_XPRV)
    end
  end

  module AccountMixin
    include AccAttrsMixin
    include WalletModelMixin
    def before_setup
      super
      @acc_balance_model = HD::Models::Account.new(@acc_balance_attrs)
      @acc_payments_model = HD::Models::Account.new(@acc_payments_attrs)
      @acc_payments_ch_model = HD::Models::Account.new(@acc_payments_ch_attrs)
    end

    def account_keychain(acc_model, private: false)
      raise "XPRV not specified" if private && acc_model.xprv.nil?
      xkey = private ? acc_model.xprv : acc_model.xpub
      keychain = BTC::Keychain.new(extended_key: xkey)
      unless keychain.depth == 3
        raise "Account keychain depth should be 3, actual: #{keychain.depth}"
      end
      keychain
    end
  end
end
