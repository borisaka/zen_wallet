module ZenWallet
  module Persistence
    class HistoryMapper < ROM::Mapper
      relation :tx_history
      register_as :history_item
      
      symbolize_keys true
      wrap(transaction: %i(txid time block_position block_time block_height fee))
    end
  end
end
