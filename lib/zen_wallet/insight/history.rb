require_relative "tx_processor.rb"

module ZenWallet
  module Insight
    # Module to manualy fetch all account transactions history
    # At moment hardcoded to clear history and fetching all new values 
    # Proposed only to use at first start
    class History
      TxParams = Struct.new(:txid, :block_header, :block_position)
      def initialize(container)
        @container = container
        @account_repo = @container.resolve("account_repo")
        @address_repo = @container.resolve("address_repo")
        @transaction_repo = @container.resolve("transaction_repo")
      end
      
      def update_history 
        max_height = @transaction_repo.max_block_height
        @account_repo.to_update.each do |acc_model|
          account_history = []
          @address_repo.pluck_address(acc_model.wallet_id, acc_model.id).each do |addr|
            LibbitcoinZMQ.fetch_history(addr, max_height).each do |tx_header|
              account_history << tx_params(tx_header)
            end
          end
          processor = TxProcessor.new(@container, acc_model)
          sort_transactions(account_history).each do |tx_params|
            processor.process(*tx_params.to_h.values)
          end
        end
      end
      
      private

      def tx_params(tx_header)
        block_header = LibbitcoinZMQ.fetch_block_header(tx_header.height)
        block_position = LibbitcoinZMQ.fetch_tx_position(tx_header.txid)
        TxParams.new(tx_header.txid, block_header, block_position)
      end

      def sort_transactions(transactions)
        txs = transactions.sort_by { |tx| [tx.block_header.height, tx.block_position] }
        txs
      end
    end
  end
end
