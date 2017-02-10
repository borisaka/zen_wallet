Sequel.migration do
  change do
    create_table(:accounts) do
      String :wallet_id, size: 50
      foreign_key [:wallet_id], :wallets, null: false
      # id is bip44 account number
      String :id, size: 50, null: false
      primary_key %i(wallet_id id)
      Integer :index, null: false
      # index %i(wallet_id index), unique: true
      unique %i(wallet_id id index)
      String :xprv
      String :xpub
    end
  end
end
