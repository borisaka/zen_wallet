Sequel.migration do
  change do
    create_table(:wallets) do
      String :id, primary_key: true
      String :encrypted_seed
      String :public_seed
      String :salt
    end
  end
end
