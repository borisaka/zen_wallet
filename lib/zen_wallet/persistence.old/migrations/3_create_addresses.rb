Sequel.migration do
  change do
    create_table(:addresses) do
      String :address, size: 50, primary_key: true
      String :wallet, size: 50
      Integer :account
      Integer :change
      Integer :index
      index %i(wallet account change index), unique: true
    end
  end
end
