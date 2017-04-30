Sequel.migration do
  change do
    create_table(:tx_history) do
      String :wallet_id, size: 50
      String :account_id, size: 50
      foreign_key %i(wallet_id account_id), :accounts, null: false
      index %i(wallet_id account_id)
      String :txid, size: 100, null: false
      foreign_key %i(txid), :transactions, null: false 
      primary_key %i(wallet_id account_id txid)
      Integer :amount
      Integer :balance
    end
  end
end
