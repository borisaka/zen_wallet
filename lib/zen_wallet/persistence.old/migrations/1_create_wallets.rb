Sequel.migration do
  change do
    create_table(:wallets) do
      String :id, size: 50, primary_key: true
      String :xprv_encrypted
      String :xpub
      String :salt
    end
  end
end
