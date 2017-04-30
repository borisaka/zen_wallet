require_relative "libbitcoin_zmq"
module ZenWallet
  module Insight
    class TxProcessor
      TxOut = Struct.new(:index, :amount, :script, :address, :wallet_id, :account_id)
      TxIn = Struct.new(:index, :prev_txid, :prev_index, :amount, :address, :wallet_id, :account_id)
      HistoryItem = Struct.new(:wallet_id, :account_id, :txid, :amount, :balance)

      def initialize(container, account)
        @container = container
        @account = account
        @transaction_repo = container.resolve("transaction_repo")
        @tx_history_repo = container.resolve("tx_history_repo")
        @tx_output_repo = container.resolve("tx_output_repo")
        @tx_input_repo = container.resolve("tx_input_repo")
        @address_repo = container.resolve("address_repo")
        @bitcoin_network = container.resolve("bitcoin_network")
      end

      def process(txid, block_header = nil, block_position = nil)
        current = @transaction_repo.detect(txid)
        history_item = current ? @tx_history_repo.detect(txid, @account.wallet_id, @account.id) : nil
        block_updated = false
        if (current && current.block_height.nil?) && block_header
          @transaction_repo.update(txid, block_height: block_header.height, block_time: block_header.time, block_position: block_position)
          block_updated = true
        end
        if current.nil?
          add_to_history(txid, block_header, block_position)
          :tx_added
        elsif history_item.nil?
          gen_history_item(txid)
          :tx_history_updated
        else
          block_updated ? :block_updated : false
        end
      end

      def add_to_history(txid, block_header, block_position)
        transaction = LibbitcoinZMQ.fetch_transaction(txid)
        inputs = build_inputs(transaction) || []
        outputs = build_outputs(transaction) || []
        @transaction_repo.create(txid: txid, 
                                 time: block_header&.time,
                                 block_position: block_position,
                                 block_time: block_header&.time,
                                 block_id: block_header&.block_id,
                                 block_height: block_header&.height)
        inputs.each { |input| @tx_input_repo.create(input.to_h.merge(txid: txid)) }
        outputs.each { |output| @tx_output_repo.create(output.to_h.merge(txid: txid)) }
        @tx_history_repo.create(gen_history_item(txid).to_h.merge(txid: txid))
      end

      def build_outputs(transaction)
        outs = transaction.outputs.map do |out| 
          TxOut.new(out.index, out.value, out.script.to_s, grab_addr(out))
        end
        append_accounts_if_any(outs)
      end

      def append_accounts_if_any(collection)
        addrs_accounts = @address_repo.find_account_ids(collection.map(&:address))
        collection.map do |item| 
          addr_hash = addrs_accounts.detect { |obj| obj[:address] == item.address } || {}
          item.class.new(*item.to_h.merge(addr_hash.to_h).values)
        end
      end

      def build_inputs(transaction)
        ins = transaction.inputs.map do |input|
          previous_transaction = LibbitcoinZMQ.fetch_transaction(input.previous_id)
          previous_output = previous_transaction.outputs[input.previous_index]
          TxIn.new(input.index, input.previous_id, input.previous_index, 
                   previous_output.value, grab_addr(previous_output)) 
        end
        append_accounts_if_any(ins)
      end

      def gen_history_item(txid)
        current_balance = @tx_history_repo.account_balance(@account.wallet_id, @account.id)
        selector = [txid, @account.wallet_id, @account.id]
        amount = @tx_output_repo.tx_account_amount(*selector) - @tx_input_repo.tx_account_amount(*selector)
        HistoryItem.new(@account.wallet_id, @account.id, txid, amount, current_balance + amount) 
      end

      def grab_addr(output)
        output.script.standard_address(network: @bitcoin_network).to_s
      end

      def calc_detail(txid, balance)
        transaction = LibbitcoinZMQ.fetch_transaction(txid)
        transaction.inputs.each do |input|
          @tx_input_repo.create(
            TxIn.new(txid, input.index, input.previous_id, input.previous_index).to_h
          )
        end
        fee = @transaction_repo.fee(txid)
        amount = @transaction_repo.amount_for_account(@account.wallet_id, @account.id)
        new_balance = balance + amount
        @transaction_repo.update(txid, fee: fee)
        #@tx_history_repo.update(@account.wallet_id, @account.id, txid, balance: new_balance, amount: amount)
      end 
    end
  end
end
