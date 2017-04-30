require "test_helper"
require "mixins/stub_repo_mixin"
require "mixins/tx_data_mixin"
require "zen_wallet/insight/tx_processor"

module ZenWallet
  module Insight
    class TxProcessorTest < Minitest::Test
      include StubRepoMixin
      include TxDataMixin
      def setup
        super
        @container = Dry::Container.new
        stub_repo(:transaction, :tx_history, :tx_input, :tx_output, :address)
        @container.register("bitcoin_network", BTC::Network.mainnet)
        @subject = TxProcessor.new(@container, OpenStruct.new(wallet_id: "W", id: "A"))
      end

      def test_process
        # if nothing to update
        @transaction_repo.stubs(:detect).with("0").returns(OpenStruct.new(block_height: nil, block_position: nil))
        @tx_history_repo.stubs(:detect).with("0", "W", "A").returns(1)
        refute @subject.process("0")
        #if block updates and tx && tx_history present
        @transaction_repo.expects(:update).with("0", block_height: 1, block_time: 2, block_position: 3)
        assert_equal :block_updated, @subject.process("0", OpenStruct.new(height: 1, time: 2), 3)
        # if new tx 
        @transaction_repo.stubs(:detect).with("1").returns(nil)
        @subject.expects(:add_to_history).with("1", nil, nil)
        assert_equal :tx_added, @subject.process("1")
        #if tx_history missed
        @transaction_repo.stubs(:detect).with("2").returns(OpenStruct.new(block_height: 1, block_position: 2))
        @tx_history_repo.stubs(:detect).with("2", "W", "A").returns(nil)
        @subject.expects(:gen_history_item).with("2")
        assert_equal :tx_history_updated, @subject.process("2", OpenStruct.new(height: 1), 2)
      end

      def test_add_to_history
        flunk "Fix Stack error!"
        LibbitcoinZMQ.stubs(:fetch_transaction).with("0").returns("TX")
        @subject.stubs(:build_inputs).with("TX").returns("INPUTS")
        @subject.stubs(:build_outputs).with("TX").returns("OUTPUTS")
        @transaction_repo.expects(:create).with(
          txid: "0", 
          time: 0,
          block_position: 1,
          block_time: 0,
          block_id: 2,
          block_height: 3,
          inputs: "INPUTS",
          outputs: "OUTPUTS"
        )
        @subject.stubs(:gen_history_item).with("0").returns(txid: "0")
        @tx_history_repo.expects(:create).with(txid: "0")
        @subject.add_to_history("0", OpenStruct.new(time: 0, block_id: 2, height: 3), 1)
      end

      def test_build_outputs
        addresses = []
        prepared = []
        expected = []
        (1..4).each do |i|
          address = stub_p2pks(i) 
          addresses << address 
          prepared << OpenStruct.new(script: address, index: i, value: i * 10_000)
          expected << TxProcessor::TxOut.new(i, i * 10_000, address.to_s, i.to_s)
        end
        transaction = OpenStruct.new(outputs: prepared)
        @subject.expects(:append_accounts_if_any).with(expected)
        @subject.build_outputs(transaction)
        end

        def test_append_accounts_if_any
          st = Struct.new(:address, :data, :wallet_id, :account_id)
          addresses = [st.new("0", "D0"), st.new("1", "D1"), st.new("2", "D2")]
          ast = Struct.new(:address, :wallet_id, :account_id)
          with_accs = [["0", "0", "0"], ["1", "0", "0"], ["2", "1", "2"]].map { |d| ast.new(*d) }
          @address_repo.stubs(:find_account_ids).with(addresses.map(&:address)).returns(with_accs)
          expected = [["0", "D0", "0", "0"], ["1", "D1", "0", "0"], ["2", "D2", "1", "2"]].map { |d| st.new(*d)}
          assert_equal expected, @subject.append_accounts_if_any(addresses)
        end

        def test_build_inputs
          inputs = [[0, "0", 0], [1, "0", 1], [2, "1", 0]].map do |data|
            Struct.new(:index, :previous_id, :previous_index).new(*data)
          end
          prev_txs = [
            OpenStruct.new(outputs: [OpenStruct.new(script: stub_p2pks(0), amount: 100),
                                     OpenStruct.new(script: stub_p2pks(1), amount: 200)]),
            OpenStruct.new(outputs: [OpenStruct.new(script: stub_p2pks(0), amount: 300)])
          ]
          expected = [
            TxProcessor::TxIn.new(0, "0", 0, 100, "0"),
            TxProcessor::TxIn.new(1, "0", 1, 200, "1"),
            TxProcessor::TxIn.new(3, "1", 2, 300, "2")
          ] 
          LibbitcoinZMQ.expects(:fetch_transaction).with("0").returns(prev_txs[0]).twice
          LibbitcoinZMQ.expects(:fetch_transaction).with("1").returns(prev_txs[1])
          transaction = OpenStruct.new(inputs: inputs)
          #@subject.expects(:append_accounts_if_any).with(expected)
          @subject.build_inputs(transaction)
        end

        def test_gen_history_item
          @tx_history_repo.stubs(:account_balance).with("W", "A").returns(120_000)
          txid = "0"
          # If accepted money
          @tx_output_repo.stubs(:tx_account_amount).with("0", "W","A").returns(20_000)
          @tx_input_repo.stubs(:tx_account_amount).with("0", "W", "A").returns(0)
          expected = TxProcessor::HistoryItem.new("W", "A", "0", 20_000, 140_000)
          assert_equal expected, @subject.gen_history_item(txid)
          #If spend money with exchange
          @tx_output_repo.stubs(:tx_account_amount).with("0", "W","A").returns(18_000)
          @tx_input_repo.stubs(:tx_account_amount).with("0", "W", "A").returns(100_000)
          expected = TxProcessor::HistoryItem.new("W", "A", "0",-82_000 , 38_000)
          assert_equal expected, @subject.gen_history_item(txid)
        end

        private
        
        def stub_p2pks(index)
          address = mock
          address.stubs(:to_s).returns("SCRIPT#{index}")
          address.stubs(:standard_address).with(network: BTC::Network.mainnet).returns("#{index}")
          address
        end
      end
    end
  end
