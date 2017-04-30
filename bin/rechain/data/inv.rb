# frozen_string_literal: true
module ZenWallet
  module Rechain
    module Data
      include Logging
      # Inv data parser and generator
      class Inv < Dry::Struct
        attribute :type, InvType
        attribute :id, InvID
      end

      # Parse payload with inventories
      def self.parse_inv(payload)
        split_inv_blob(*Utils::VarInt.extract(payload)).map do |(type, hash)|
          logger.debug("Creating inv: #{type} with #{hash}")
          Inv.new(type: type, id: hash)
        end
      end

      def self.split_inv_blob(len, data)
        items = data.scan(/.{36}/)
        logger.debug("Processing inv #{items} with len #{len}")
        raise "Len and inv count missmatch" unless items.length == len
        items.map { |i| i.unpack("Va*") }
      end

      # Pack deserialized items to bitcoin message
      def self.pack_inv(items)
        binary = items.map do |inv|
          reverse_inv_types = { tx: 1, block: 0 }
          ar = [reverse_inv_types[inv.type], InvHash[inv.id]]
          ar.pack("Va*")
        end
        Utils::VarInt.pack(binary)
      end
    end
  end
end
