# frozen_string_literal: true
module ZenWallet
  module Rechain
    module Msg
      # Inv(hashes of transactions and blocks) parsing
      class Inv < AbstractMsg
        Item = Struct.new(:type, :id)
        def handle(payload)
          logger.info("Handle inv #{payload}")
          split_invdata(payload).map { |i| parse_item(i) }
        end

        private

        # Splits inv data to items
        def split_invdata(payload)
          # logger.debug("Parsing inv #{payload}")
          # parser = Hash.new("Ca*").merge(0xFD => "xv1a*",
          #                                0xFE => "xV1a*",
          #                                0xFF => "xQ<1a*")
          tuple = payload.unpack(parser[payload.unpack("C")[0]])
          items = tuple[1].scan(/.{36}/)
          raise "Package Broken" unless items.length == tuple[0]
          items
        end

        # parse binary item
        def parse_item(item)
          types = { 1 => :tx, 2 => :block }
          tuple = item.unpack("V1a*")
          Item.new(types[tuple[0]], tuple[1].reverse.unpack("H*")[0])
        end
      end
    end
  end
end
