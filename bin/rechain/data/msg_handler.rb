# frozen_string_literal: true
require "dry-struct"
require "dry-types"
require "dry-validation"
require "dry/validation/extensions/monads"
require_relative "validation"
module ZenWallet
  module Rechain
    module Data
      class MsgHandler
        ChecksumMismatch = ::Class.new(StandardError)
        BadMagic = ::Class.new(StandardError)
        class BasicMsg < Dry::Struct
          attribute :msg_type, MsgType
          attribute :payload, MsgPayload
        end

        class Msg < BasicMsg
          attribute :magic, Magic
          attribute :length, MsgLength
          attribute :checksum, MsgChecksum
        end

        def initialize(network)
          @network = network
        end

        def gen_msg(msg)
          msg.to_h.values_at(:magic, :msg_type, :length, :checksum, :payload)
             .pack("a4A12Va4a*")
        end

        def pack_msg(msg)
          case msg
          when Msg then gen_msg(msg)
          when BasicMsg
            attrs = msg.to_h.merge(magic: msg.network.magic,
                                   length: msg.payload.length,
                                   checksum: ChkSum[msg.payload])
            gen_msg(Msg.new(attrs))
          else raise "Wrong format"
          end
        end

        def parse_chunk(chunk, chunk_name)
          case chunk_name
          when :magic
            raise BadMagic unless chunk == @network.magic
            chunk
          when :head
            chunk.unpack("A12Va4")
          else raise "Unknown chunk. #{chunk}"
          end
        end

        def read_stream(stream)
          magic = parse_chunk(stream.recv(4), :magic)
          msg_type, length, checksum = parse_chunk(stream.recv(20), :head)
          payload = check_payload_sum(stream.recv(length), checksum)
          Msg.new(msg_type: msg_type,
                  magic: magic,
                  length: length,
                  checksum: checksum,
                  payload: payload)
        end

        def read_str(str)
          attrs = {}
          attrs[:magic] = parse_chunk(str[0..3], :magic)
          attrs[:msg_type], attrs[:length], attrs[:checksum] =
            parse_chunk(str[4..24], :head)
          payload = check_payload_sum(str[24..attrs[:length]], checksum)
          Msg.new(msg_type: msg_type,
                  magic: magic,
                  length: length,
                  checksum: checksum,
                  payload: payload)
        end

        private

        def check_payload_sum(payload, checksum)
          raise ChecksumMismatch unless ChkSum[payload] == checksum
          payload
        end
      end
    end
  end
end
