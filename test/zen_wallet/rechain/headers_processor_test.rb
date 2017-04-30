require "test_helper"
require "zen_wallet/rechain/headers_processor"
require "zen_wallet/rechain/block_store"
require "btcruby"
module ZenWallet
  module Rechain
    class HeadersProcessorTest < Minitest::Test
      def setup
        container = Dry::Container.new
        @store = mock
        @store.responds_like_instance_of(BlockStore)
        container.register("block_store", @store)
        @gb = "000000000933ea01ad0ee984209779baaec3ced90fa3f408719526f8d77f4943"
        # @network = mock
        # @network.responds_like(BTC::Network.testnet)
        # @network.stubs(:genesis_block_header)
                # .returns(OpenStruct.new(block_id: "000"))
        container.register("bitcoin_network", BTC::Network.testnet)
        container.register("logger", Logger.new(STDOUT))
        @subject = HeadersProcessor.new(container)
      end

      def test_locators
        @store.expects(:last_ids)
              .with(HeadersProcessor::MAX_LOCATORS)
              .returns([])
        assert_equal [@gb], @subject.locators
        @store.expects(:last_ids)
              .with(HeadersProcessor::MAX_LOCATORS)
              .returns(["111"])
        assert_equal ["111"], @subject.locators
      end

      def test_process_chunk
        fid = "fafbe36aa17ddc31d1ae4dd79f0fc2ea170c37bb963a5d83cc08e720876e8d7c"
        chunk = [BTC::BlockHeader.new(previous_block_id: @gb)]
        # store with genesis
        @store.stubs(:detect).with(@gb).returns(nil)
        @store.expects(:append)
              .with(includes(has_entries("previous_id" => @gb, "height" => 1)))
        @subject.process_chunk(chunk)
        # store with persisted
        chunk = [BTC::BlockHeader.new(previous_block_id: fid)]
        @store.stubs(:detect).with(fid).returns({"id" => fid, "height" => 1})
        @store.expects(:append)
              .with(includes(has_entries("previous_id" => fid, "height" => 2)))
        @subject.process_chunk(chunk)
        # raises wrong order
        chunk = [BTC::BlockHeader.new(previous_block_id: fid)]
        @store.stubs(:detect).with(fid).returns({"id" => @gb})
        assert_raises(HeadersProcessor::WrongBlockOrder) do
          @subject.process_chunk(chunk)
        end
      end

      def test_process
        headers = (0..249).to_a
        chunks = [(0..99).to_a, (100..199).to_a, (200..249).to_a]
        chunks.each do |chunk|
          @subject.expects(:process_chunk).with(equals(chunk))
        end
        @subject.process(headers)
      end
    end
  end
end
