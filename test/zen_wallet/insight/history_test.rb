require "test_helper"
require "mixins/stub_repo_mixin"
require "zen_wallet/insight/history"
module ZenWallet
  module Insight
    class HistoryTest < Minitest::Test
      include StubRepoMixin 
      def setup
        @container = Dry::Container.new
        stub_repo(:transaction, :account, :address)
        @subject = History.new(@container)
      end
      def test_update_history
        @transaction_repo.stubs(:max_block_height).returns(9)
        accounts = [
          { wallet_id: "W1", account_id: "A1" },
          { wallet_id: "W1", account_id: "A2" }
        ].map { |hs| OpenStruct.new(hs) }
        @account_repo.stubs(:to_update).returns(accounts)
        @address_repo.stubs(:pluck_address).with("W1", "A1").returns(["ADDR1"])
        @address_repo.stubs(:pluck_address).with("W1", "A2").returns(["ADDR2", "ADDR3"])
        txHead = Struct.new(:txid, :height) 
        blockHead = Struct.new(:height)
        LibbitcoinZMQ.stubs(:fetch_history).with("ADDR1", 9).returns(
          [txHead.new("T1", 1), txHead.new("T2", 5), txHead.new("T3", 2)]
        )
        LibbitcoinZMQ.stubs(:fetch_history).with("ADDR2", 9).returns(
          [txHead.new("T4", 5), txHead.new("T5", 1), txHead.new("T6", 1)]
        )
        LibbitcoinZMQ.stubs(:fetch_history).with("ADDR3", 9).returns(
          [txHead.new("T7", 3), txHead.new("T8", 2), txHead.new("T9", 1)]
        )
        LibbitcoinZMQ.stubs(:fetch_tx_position).with("T1").returns(5)
        LibbitcoinZMQ.stubs(:fetch_tx_position).with("T2").returns(8)
        LibbitcoinZMQ.stubs(:fetch_tx_position).with("T3").returns(21)
        LibbitcoinZMQ.stubs(:fetch_tx_position).with("T4").returns(2)
        LibbitcoinZMQ.stubs(:fetch_tx_position).with("T5").returns(15)
        LibbitcoinZMQ.stubs(:fetch_tx_position).with("T6").returns(24)
        LibbitcoinZMQ.stubs(:fetch_tx_position).with("T7").returns(11)
        LibbitcoinZMQ.stubs(:fetch_tx_position).with("T8").returns(4)
        LibbitcoinZMQ.stubs(:fetch_tx_position).with("T9").returns(6)
        #T1[1,5], T9[1,6] T5[1,15], T6[1, 24], T8[2, 4], T3[2, 21], T7[3,11], T4[5, 2], T2[5, 8]
        blocks = [1, 2, 3, 5].map { |i| OpenStruct.new(height: i) }
        blocks.each do |blk|
          LibbitcoinZMQ
            .stubs(:fetch_block_header)
            .with(blk.height)
            .returns(blk)
        end
        order = %w(T1 T9 T5 T6 T8 T3 T7 T4 T2)
        processor = mock
        processor.responds_like_instance_of(TxProcessor)
        TxProcessor.stubs(:new).returns(processor)
        #order.each {|o| processor.expects(:process).with(o)  }
        processor.expects(:process).with("T1", blocks[0], 5)
        processor.expects(:process).with("T9", blocks[0], 6)
        processor.expects(:process).with("T5", blocks[0], 15)
        processor.expects(:process).with("T6", blocks[0], 24)
        processor.expects(:process).with("T8", blocks[1], 4)
        processor.expects(:process).with("T3", blocks[1], 21)
        processor.expects(:process).with("T7", blocks[2], 11)
        processor.expects(:process).with("T4", blocks[3], 2)
        processor.expects(:process).with("T2", blocks[3], 8)
        @subject.update_history
      end
    end
  end
end
