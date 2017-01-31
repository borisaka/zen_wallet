# frozen_string_literal: true
require "dry-equalizer"
require "dry-initializer"
require "zen_wallet/insight"
require "zen_wallet/insight/models"
require "zen_wallet/transaction_builder"
module ZenWallet
  module HD
    class Account
      extend Dry::Initializer::Mixin
      include Dry::Equalizer(:public_key)
      param  :wallet
      option :id
      option :order
      option :private_key
      option :public_key
      option :address

      def fetch_balance(only_confirmed = false)
        attrs = Insight.client.balance(address)
        if only_confirmed
          attrs[:balanceSat]
        else
          attrs[:balanceSat] + attrs[:unconfirmedBalanceSat]
        end
      end

      def fetch_tx_history
        Insight.client.tx_history_all(address)
      end

      def spend(outputs, fee, passphrase = "")
        sender_pk = private_key
        unless sender_pk
          sender_pk = wallet.private_key_for(id, passphrase)
        end
        utxo = fetch_utxo
        attrs = {
          utxo: utxo,
          outputs: outputs,
          fee: fee,
          private_key_wif: sender_pk,
          change_address: address
        }
        raw_tx = TransactionBuilder.build_transaction(**attrs).to_hex
        Insight.client.broadcast_tx(raw_tx)
      end

      def fetch_utxo
        Insight.client.utxo(address)
      end
    end
  end
end
