require "test_helper"
require "zen_wallet/insight/libbitcoin_zmq.rb"
module ZenWallet
  module Insight
    class LibbitcoinZMQTest < Minitest::Test
      def setup
        @subject = LibbitcoinZMQ
        @addr = "mmKZdz6H434VQoPSJLfG19so8sLPu5edpN"
        @pack_addr = "o?\xA9D<]\xF4V\x16\xF6\xF5\e\xACG\xAF\xFFk\xDD\xB6\x9FC".b
        @txid0 = "312320e024e402e7e15cb630a6a1c507fc7725e5fa2deeefaf965a3cb119dbbf"
        @txid1 = "ffdc9829abcc2c500913ae67c8a28397a5d5566ad1ed1ac5cdbd81a4a3e5a83f"
        @txhsh0 = "\xBF\xDB\x19\xB1<Z\x96\xAF\xEF\xEE-\xFA\xE5%w\xFC\a\xC5\xA1\xA60\xB6\\\xE1\xE7\x02\xE4$\xE0 #1".b
        @txhsh1 = "?\xA8\xE5\xA3\xA4\x81\xBD\xCD\xC5\x1A\xED\xD1jV\xD5\xA5\x97\x83\xA2\xC8g\xAE\x13\tP,\xCC\xAB)\x98\xDC\xFF".b
      end

      def test_fetch_history
        payload = [[0, @txhsh0, 0, 0, "0"], [1, @txhsh1, 0, 1, "0"]].map { |hargs| hargs.pack("CA32VVA8") }.join
        @subject.stubs(:request).with("blockchain.fetch_history2", @pack_addr + [0].pack("V")).returns(payload)
        expected = [LibbitcoinZMQ::TxHeader.new(@txhsh0, @txid0, 0), LibbitcoinZMQ::TxHeader.new(@txhsh1, @txid1, 1)]
        assert_equal expected, @subject.fetch_history(@addr, 0)
      end

      def test_fetch_transaction
        @subject.stubs(:request).with("blockchain.fetch_transaction", @txhsh0).returns("RAW")
        BTC::Transaction.stubs(:new).with(data: "RAW").returns("TRANSACTION")
        assert_equal "TRANSACTION", @subject.fetch_transaction(@txid0)
      end

      def test_fetch_tx_position
        payload = "\x02\x00\x00\x00\x03\x00\x00\x00".b
        @subject.stubs(:request).with("blockchain.fetch_transaction_index", @txhsh0).returns(payload)
        assert_equal 3, @subject.fetch_tx_position(@txid0)
      end

      def test_fetch_block_header
        request = "\x04\x00\x00\x00".b
        @subject.stubs(:request).with("blockchain.fetch_block_header", request).returns("HEADER")
        BTC::BlockHeader.stubs(:new).with(data: "HEADER").returns("GOOD_HEADER")
        assert_equal "GOOD_HEADER", @subject.fetch_block_header(4)
      end
    end
  end
end
