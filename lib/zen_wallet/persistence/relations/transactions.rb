module ZenWallet
  module Persistence
    class Transactions< ROM::Relation[:sql]
      register_as :transactions
      dataset :transactions
      schema(infer: true) do
        associations do
          has_many :tx_outputs, as: :outputs, foreign_key: :txid
          has_many :tx_inputs, as: :inputs, foreign_key: :txid
          has_many :tx_history, as: :history_items, foreign_key: :txid
        end
      end
    end
  end
end 
