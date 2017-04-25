Sequel.migration do
  change do
    create_table(:addresses) do
      String :address, size: 50, primary_key: true
      String :wallet_id, size: 50
      foreign_key [:wallet_id], :wallets, null: false
      String  :account_id, size: 50
      foreign_key %i(wallet_id account_id), :accounts, null: false
      index %i(wallet_id account_id)
      Integer :chain
      Integer :index
      index %i(wallet_id account_id chain index), unique: true
      TrueClass :has_txs, default: false
      TrueClass :requested, default: false
    end
  end
end
