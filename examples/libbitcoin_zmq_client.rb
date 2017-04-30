require "pry"
require "zmq"
require "btcruby"
#requi
#socket = ctx.socket(:REQ)
#socket.connect(endpoint)
#socket.linger = 1

WrongStatusCode = Class.new(StandardError)
TxHeader = Struct.new(:zmq_hash, :id, :height)

def connect
  ctx = ZMQ::Context.new
  endpoint = "tcp://50.244.13.28:19091"
  socket = ctx.connect(:DEALER, endpoint)
  socket.verbose = true
  socket
end

def request(cmd, payload)
  socket = connect
  #request = "blockchain.fetch_last_height"
  msg = ZMQ::Message.new
  msg.add(ZMQ::Frame(cmd))
  msg.add(ZMQ::Frame([rand(254)].pack("V")))
  msg.add(ZMQ::Frame(payload))
  socket.send_message(msg)
  buf = StringIO.new(socket.recv_message.last.data)
  status = buf.gets(4).unpack("V")[0]
  raise WrongStatusCode unless status.zero?
  buf
end

def fetch_history(addr)
  address = BTC::PublicKeyAddress.new(string: addr, network: BTC::Network.testnet)
  io = request("blockchain.fetch_history2", address.data_for_base58check_encoding + [0].pack("V"))
  history = []
  until io.eof? do
    chunk = io.gets(49)
     _, hash, _, height = chunk.unpack("CA32VV")
    history << TxHeader.new(hash, hash.unpack("h*")[0].reverse, height)
  end
  history
end

def fetch_transaction(header)
  io = request("blockchain.fetch_transaction", header.zmq_hash)
end

tx_headers = [
  TxHeader.new("\xFAL\x00\x9A\xDE\xEFy\xF1\xB2\xF9\x89\xE9}V~\x1F\x1E\x85\x15c>\xE9c\xC2sm\xD5\xA2c\x1F\x1E\xCC".b, 
               "cc1e1f63a2d56d73c263e93e6315851e1f7e567de989f9b2f179efde9a004cfa",
               1088615), 
  TxHeader.new("\xCD\x88N\xE6\x85\xFA\xC1\xC4\xB4\xF0\x16\x1F]i\xE2\xEB_\xC1uW:\x9A\xD00n\xFA\xED\x02)\x900v", 
               "7630902902edfa6e30d09a3a5775c15febe2695d1f16f0b4c4c1fa85e64e88cd",
               1088098)
]
tx = fetch_transaction(tx_headers[0])

