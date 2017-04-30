require "zmq"
require "btcruby"

module ZenWallet
  module Insight
    module LibbitcoinZMQ
      module_function

      WrongStatusCode = Class.new(StandardError)
      TxHeader = Struct.new(:zmq_hash, :txid, :height)
      def connect
        return @socket if @socket
        ctx = ZMQ::Context.new
        #endpoint = "tcp://138.197.230.58:19091"
        endpoint = "tcp://testnet1.libbitcoin.net:19091"
        @socket = ctx.connect(:DEALER, endpoint)
        @socket.verbose = true
        @socket
      end

      def request(cmd, payload)
        socket = connect
        msg = ZMQ::Message.new
        msg.add(ZMQ::Frame(cmd))
        msg.add(ZMQ::Frame([rand(254)].pack("V")))
        msg.add(ZMQ::Frame(payload))
        socket.send_message(msg)
        response = socket.recv_message.last.data
        status = response[0..3].unpack("V")[0]
        #binding.pry
        raise WrongStatusCode, "#{status}" unless status.zero?
        response[4..-1] 
      end

      # Fetches history from block with given height
      # @param addr [String] given bitcoin address
      # @param height [String] start block height
      def fetch_history(addr, height)
        address = BTC::PublicKeyAddress.new(string: addr)
        payload = request("blockchain.fetch_history3", address.data + [height].pack("V"))
        points = []
        payload.chars.each_slice(49) { |chars| points << chars.join }
        points.map do |point| 
          _, hash, _, height = point.unpack("CA32VV")
          TxHeader.new(hash, hash.unpack("h*")[0].reverse, height)
        end
      end

      def fetch_transaction(txid)
        payload = request("blockchain.fetch_transaction", hash_from_txid(txid))
        BTC::Transaction.new(data: payload)
      end

      def fetch_tx_position(txid)
        request("blockchain.fetch_transaction_index", hash_from_txid(txid)).unpack("VV")[1]
      end

      # Fetches block_header by height from tx
      def fetch_block_header(height)
        payload = request("blockchain.fetch_block_header", [height].pack("V"))
        BTC::BlockHeader.new(data: payload, height: height)
      end

      def hash_from_txid(txid)
        [txid.reverse].pack("h*")
      end
    end
  end
end
