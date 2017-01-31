Sequel.migration do
  change do
    create_table(:chain_addresses) do
      String :address, size: 50, primary_key: true
      String :wallet_id, size: 100
      String :account_id
      BigNum :change, index: true
      BigNum :order, index: true
      String :private_key, size: 250
      String :public_key, size: 250
      index %i(account_id change order), unique: true
      foreign_key [:wallet_id, :account_id], :accounts
    end
  end
end
