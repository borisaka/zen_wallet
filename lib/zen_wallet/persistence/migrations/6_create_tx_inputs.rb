Sequel.migration do
  change do
    create_table(:tx_inputs) do
      String :txid, size: 100, null: false
      foreign_key %i(txid), :transactions, null: false
      Integer :index
      primary_key %i(txid index)
      String :prev_txid, size: 100, index: true, null: false
      Integer :prev_index, null: false
      index %i(prev_txid prev_index), unique: true 
      Integer :amount, null: false
      String :address, size: 50, null: false
      String :wallet_id, size:50
      foreign_key %i(wallet_id), :wallets
      String :account_id, size: 50
      foreign_key %i(wallet_id account_id), :accounts
    end
    #alter_table(:tx_outputs) do
    #  add_foreign_key %i(spent_txid spent_index), :tx_inputs
    #end
  end
end
