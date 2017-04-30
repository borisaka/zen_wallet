module ZenWallet
  module Rechain
    module Protocol
      MESSAGE_TYPES =
        %w(addr alert block blocktxn cmpctblock feefilter filteradd filterclear
           filterload getaddr getblocks getdata getblocktxn getheaders headers
           inv mempool merkleblock notfound ping pong reject sendcmpct
           sendheaders tx verack version).freeze
    end
  end
end
