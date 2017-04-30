Sequel.migration do
  change do
    create_table(:tx_outputs) do
      String :txid, size: 100, null: false, index: true
      foreign_key %i(txid), :transactions, null: false
      Integer :index
      primary_key %i(txid index)
      Integer :amount
      String :address, size: 50, index: true, null: false
      String :script, null: false
      String :wallet_id, size: 50
      foreign_key %i(wallet_id), :wallets
      String :account_id, size: 50
      foreign_key %i(wallet_id account_id), :accounts  
    end
  end
end
