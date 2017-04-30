  Sequel.migration do
    change do
      create_table(:transactions) do
        String :txid, size: 100, primary_key: true
        DateTime :time, index: true
        Integer :block_position
        DateTime :block_time, index: true
        String :block_id, size: 100, index: true
        Integer :block_height
        Integer :fee
        Integer :amount
     end
   end
 end
