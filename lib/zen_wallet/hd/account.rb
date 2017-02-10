# frozen_string_literal: true
# require "zen_wallet/insight/models"
# require "zen_wallet/transaction_builder"
# require_relative "address"
module ZenWallet
  module HD
    class Account
      GAP_LIMIT = 19 #this is whery smart
      GapLimitIsOver = Class.new(StandardError)
      attr_reader :model
      def initialize(container, model)
        @model = model
        @keychain = BTC::Keychain.new(extended_key: model.xprv || model.xpub)
        @address_repo = container.resolve("address_repo")
        @network = container.resolve("bitcoin_network")
        @balance = Insight::Balance.new(self, @network)
      end

      def balance
        @balance.amount
      end

      def trusted?
        !@model.xprv.nil?
      end

      def pluck_addresses
        @address_repo.pluck_address(@model.wallet_id, @model.index)
      end

      def request_recv_address
        address = @address_repo.next_unused_recv(@model.wallet_id, @model.index)
        @address_repo.mark_as_requested(address)
      end

      def handle_transaction(transaction)
        gap = load_gap_addresses
        tx_addrs = transaction.address_details.map(&:address)
        now_used_addresses = gap.select { |ga| tx_addrs.include?(ga.address) }
        now_used_addresses.each do |addr|
          @address_repo.mark_as_requested(addr) unless addr.requested
          @address_repo.mark_as_used(addr)
        end
        create_gap_addresses
      end

      def load_gap_addresses
        @address_repo.unused_recvs(@model.wallet_id, @model.index)
      end

      private

      def load_gap_size
        @address_repo.gap_size(@model.wallet_id, @model.index)
      end

      # Reserving full GAP_LIMIT and wach it. do not use
      def create_gap_addresses
        load_gap_size.upto(GAP_LIMIT) { gen_receive_address }
      end

      def gen_receive_address
        index = @address_repo.next_index(@model.wallet_id, @model.index)
        pkey = @keychain.bip44_external_keychain.derived_key(index)
        addr = pkey.address(network: @network).to_s
        model = Models::Address.new(
          wallet_id: @model.wallet_id, account_index: @model.index,
          change: 0, index: index, address: addr, has_txs: false,
          requested: false
        )
        @address_repo.find_or_create(model)
        model
      end

      def collect_utxo(amount)
      end

      # def spend(outputs, fee, passphrase = "")
      #   sender_pk = private_key
      #   unless sender_pk
      #     sender_pk = wallet.private_key_for(id, passphrase)
      #   end
      #   utxo = fetch_utxo
      #   attrs = {
      #     utxo: utxo,
      #     outputs: outputs,
      #     fee: fee,
      #     private_key_wif: sender_pk,
      #     change_address: address
      #   }
      #   raw_tx = TransactionBuilder.build_transaction(**attrs).to_hex
      #   Insight.client.broadcast_tx(raw_tx)
      # end
      #
      # def fetch_utxo
      #   Insight.client.utxo(address)
      # end
    end
  end
end
