# frozen_string_literal: true
module ZenWallet
  module Rechain
    # Utils to encode/decode bitcoin protocol data
    module Utils
      module_function

      # Bitcoin Compact size.
      #   First byte tells about size of length value (first 1-9 bytes)
      # @see https://en.bitcoin.it/wiki/Protocol_documentation#Variable_length_integer
      module VarInt
        module_function

        # If < 253 invs: use 8bit intefer
        #   if more - 16....
        PACKS = %w(C xv xV xQ<).freeze
        VALUES = [0xFD, 0xFFFF, 0xFFFFFFFF].freeze
        # Bitcoin constants to make a clean how long length variable
        LABELS = [0xFD, 0xFE, 0xFF].freeze

        # Basicly extracting number from inv payload
        def self.extract(payload)
          byte = payload.unpack("C")[0]
          pack = PACKS[LABELS.index(byte) || 0]
          payload.unpack(format("%sa*", pack))
        end

        # Packing serialized items into single blob
        def self.pack(bin_items)
          index = VALUES.index(VALUES.bsearch { |v| v > bin_items.length })
          payload = []
          payload << [LABELS[index]].pack("C") if index.positive?
          payload << [bin_items.length].pack(PACKS[index])
          payload << bin_items.pack("a*")
          payload.join
        end
      end

      def inv_hash2id(inv_hash)
        return inv_hash if /\h*/i.match(inv_hash)[0] == inv_hash # this is hex
        inv_hash.reverse.unpack("H*")[0]
      end

      def inv_id2hash(inv_id)
        return inv_id if inv_id.encoding.name == "ASCII-8BIT" # this is binary
        [inv_id].pack("H*").reverse
      end
    end
  end
end
