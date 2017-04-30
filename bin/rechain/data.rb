# frozen_string_literal: true
require "dry-types"
require "dry-validation"
require "dry/validation/extensions/monads"
require_relative "data/utils"
require_relative "p2p/network"
require_relative "protocol"
require_relative "data/logging"
# require_relative "data/inv"
module ZenWallet
  module Rechain
    # Data structures
    module Data
      extend Logging
      include Dry::Types.module

      INV_TYPES = { 1 => :tx, 2 => :block }.freeze
      InvType = Symbol.constrained(included_in: %i(tx block))
                      .constructor do |data|
        case data
        when ::Array then data[0]
        when ::Integer then INV_TYPES[data]
        when ::String then data.to_sym
        when ::Symbol then data
        else raise "Could not parse inv data #{data}"
        end
      end
      Network = Object
      Magic = Strict::String.constrained(size: 4)
      MsgChecksum= Strict::String.constrained(size: 4)
      MsgType = Strict::String.enum(*Protocol::MESSAGE_TYPES)
      MsgLength = Strict::Int
      MsgPayload = Strict::String

      # Hash generation
      InvID = Coercible::String.constructor {|hsh| Utils.inv_hash2id(hsh) }
      InvHash = Coercible::String.constructor { |id| Utils.inv_id2hash(id) }
      Sha256 = String.constructor { |input| Digest::SHA256.digest(input) }
      DSha256 = String.constructor { |input| Sha256[Sha256[input]] }
      ChkSum = String.constructor { |input| DSha256[input][0..3] }
    end
  end
end

require_relative "data/msg"
require_relative "data/inv"
