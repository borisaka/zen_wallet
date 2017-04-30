require_relative "account"
module ZenWallet
  module TxDataMixin
    include AccountMixin
    def setup
      super
      tx_time = Time.now
      block_time = tx_time - 6000
      bal_add = { wallet_id: WalletConstants::ID, account_id: AccConstants::Balance::ID }
      serv_add = { wallet_id: WalletConstants::ID, account_id: AccConstants::Payments::ID }
      @tx_attrs = { txid: "1", 
                 time: tx_time, 
                 block_position: 0,
                 block_time: block_time,
                 block_id: "33332",
                 block_height: 240 }
      @tx_inputs = [
        { index: 0, prev_txid: "0", prev_index: 0, amount: 20_000, address: "0" }.merge(bal_add), 
        { index: 1, prev_txid: "0", prev_index: 5, amount: 80_000, address: "1" }.merge(bal_add)
      ]
      @tx_outputs = [
        { index: 0, address: "2", script: "0", amount: 70_000 }.merge(serv_add),
        { index: 1, address: "1", script: "1", amount: 20_000 }.merge(bal_add)
      ].map { |i| i.merge(wallet_id: nil, account_id: nil) }
      @tx_full_attrs = @tx_attrs.merge(inputs: @tx_inputs, outputs: @tx_outputs)
    end
  end
end
