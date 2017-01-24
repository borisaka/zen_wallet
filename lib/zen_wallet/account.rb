# frozen_string_literal: true
require "dry-equalizer"
require "dry-initializer"
require_relative "Browser"
module ZenWallet
  # Bip42 account manipulation
  class Account
    extend Dry::Initializer::Mixin
    include Dry::Equalizer(:public_key)
    param :wallet
    option :id
    option :private_key
    option :public_key
    option :address

    def fetch_balance
      Browser.new.balance(address)[:balanceSat]
    end

    private

    def fetch_utxo
      Browser.new.utxo(address)
    end
  end
end
