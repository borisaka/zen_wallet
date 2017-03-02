# frozen_string_literal: true
require "zen_wallet/insight"
require "zen_wallet/bitcoin/tx_helper"
require_relative "account/registry"
require_relative "store"
# require "zen_wallet/transaction_builder"
# require_relative "address"
module ZenWallet
  module HD
    # BIP44 account (not yet full) implementation
    # Is a money control unit. account has a balance, generates,
    #   child addresses
    # Account can be 'regular' or 'trusted'
    # 'regular' keeps in repo only 'xpub' and allows generate and listen
    #   all account addresses. spending requires to unlock wallet and send
    #   xprv as parameter to payment/sign operation
    # 'trusted' keeps xprv and allow to spending any money from account.
    #  enduser must be notificated when account created as 'trusted'
    # @todo  addresses discovery
    #
    class Account
      include CommonStructs
      PrivateKeychainRequired = Class.new(StandardError)
      # def_delegators :@model, :id, :wallet_id

      # @param container [#resolve] IoC container with necessary object
      #   container must conain address_repo
      #   and bitcoin_network [BTC::Network]
      # @param model [Models::Account] instance with stored attributes
      def initialize(container, model)
        @model = model
        @keychain = BTC::Keychain.new(extended_key: @model.xprv || @model.xpub)
        @address_repo = container.resolve("address_repo")
        @network = container.resolve("bitcoin_network")
        @registry = Registry.new(@model, @address_repo, @network,
                                 @keychain.public_keychain)
        @store = Store.new(container.resolve("rethinkdb"), @model)
      end

      # flag if account trusted
      # @return [Boolean]
      def trusted?
        !@model.xprv.nil?
      end

      def index
        @model.index
      end

      # Next receiver address
      #   respect BIP44 GAP limit
      #   Also subcat addresses to 'requested' or not.
      #   'requested' meen that address seen by end-user or other system
      #   and may be shared to someone by payment request.
      #   account try to use address what is not requested
      #   'requested' addresses will use only if gap limit is full
      # @return [Models::Address] bitcoin external chain address
      def request_receive_address
        @registry.fill_gap_limit
        address = @registry.free_address(Registry::EXTERNAL_CHAIN)
        @registry.ensure_requested_mark(address)
        address
      end

      # Free address from EXTERNAL_CHAIN. requests new if does not find
      def receive_address
        address = @registry.free_address(Registry::EXTERNAL_CHAIN)
        address || request_receive_address
      end

      # Free address from INTERNAL_CHAIN
      def change_address
        @registry.free_address(Registry::INTERNAL_CHAIN)
      end

      # Balance from utxo
      def balance
        # make_insight.balance.total
        @store.utxo.balance
      end

      def utxo
        make_insight.balance.utxo
        # @store.utxo.load.map do |uh|
        #   Insight::Models::Utxo.new(uh.map{ |k, v| [k.to_sym, v] }.to_h)
        # end
      end

      # Loads transactions history
      def history(from = 0, to = 20)
        @store.transactions.load(from, to)
        # make_insight.transactions(from, to)
        # now_used = history.map { |h| h[:used_addresses] }.flatten.uniq
        # unless now_used.empty?
        #   @registry.ensure_has_txs_mark(now_used)
        #   @registry.fill_gap_limit
        # end
      end

      def update
        # insight = make_insight
        # fresh_txs = insight.transactions(0, 3).txs
        # return if @store.transactions.exists?(fresh_txs)
        # step = 50
        # from, to = 0, step
        # loop do
          # history = insight.transactions(from, to)
          # break if history.count.zero?
        make_insight.fetch_history do |txs|
          new_txs = @store.transactions.compare_and_save(txs)
          @store.utxo.update(new_txs)
          now_used = new_txs.map { |tx| tx["used_addresses"] }.flatten
          @registry.ensure_has_txs_mark(now_used)
          new_txs
        end
        @store.utxo.find_and_remove_spent
        @registry.fill_gap_limit
      end

      # Current balance of account
      # it a sum of derived addresses utxos amount
      # @todo add detalization about txs count, total spent, receives, etc..
      # @todo discover notmaly
      # def fetch_and_store_balance
      #   detailed_balance = insight.balance
      #   @store.store_balance(@model, detailed_balance.total)
      #   detailed_balance
      # end

      # Spends money to specified outputs
      # @param outputs [Array<String, Int>]
      #  contain array of hashes with address and amount in sat
      #  { address: "1HXEpDY2CpY7CLsWGdaUdkRY4Q1GgPqTnM", amount: 100000000 }
      # @param fee [Integer] manualy specified fee
      # @param keychain [BTC::keychain] keychain with xprv to this account
      #  requires if account not trusted and keep xprv in store
      #  you can unlock wallet to do whis @see Wallet#unlock_account
      #  if account trusted, parameter would be ignores
      # @return [String] txid of new transaction
      # @raise [PrivateKeyRequired] if nor account trusted and keychain
      #   specified
      # @raise [NotEnoughMoney] if balance amount less when summary outputs
      #   amount + fee
      # @todo feeperkb
      def spend(outputs, fees, keychain = nil)
        raise PrivateKeychainRequired unless keychain || @model.xprv
        keychain ||= BTC::Keychain.new(xprv: @model.xprv)
        proposal = tx_proposal(outputs, fees, change_address)
        tx_helper = Bitcoin::TxHelper.new(proposal, balance, utxo)
        raw = tx_helper.build { |addrsses| provide_keys(addrsses, keychain) }
        txid = make_insight.broadcast(raw)
        update
        txid
      end

      # def update_addresses_from
      #   fetch_balance&.addresses&.each do |address_obj|
      #     @registry.ensure_has_txs_mark(address_obj.address)
      #   end
      #   @registry.fill_gap_limit
      # end

      private

      def provide_keys(addresses, prv_keychain)
        touple_kls = Struct.new(:address, :key)
        addr_objects = @address_repo.find(addresses)
        addr_objects.map do |address_obj|
          key = prv_keychain.derived_keychain(address_obj.chain)
                            .derived_key(address_obj.index)
          touple_kls.new(address_obj.address, key)
        end
      end

      def tx_proposal(outputs, fees, change_address)
        strict_outs = outputs.map { |out| AddressAmount.new(**out) }
        TxProposal.new(
          outputs: strict_outs,
          fees: fees,
          change_address: change_address
        )
      end

      def make_insight
        Insight.new(@network, @model, @registry.pluck_addresses)
      end
    end
  end
end
