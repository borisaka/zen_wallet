Sequel.migration do
  change do
    create_table(:accounts) do
      String :id, size: 50
      foreign_key :wallet_id, :wallets, type: "varchar(250)"
      Integer :order, index: true
      String :private_key, size: 250
      String :public_key, size: 250
      String :address, size: 250
      primary_key [:wallet_id, :id], name: :accounts_pk
    end
  end
end
