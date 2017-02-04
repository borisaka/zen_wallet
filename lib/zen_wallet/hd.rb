# frozen_string_literal: true
require "dry-types"
require "dry-struct"
require "btcruby"
module ZenWallet
  module HD
    module Types
      include Dry::Types.module
    end

    class Model < Dry::Struct
    end
  end
end

require_relative "hd/abstract"
require_relative "hd/wallet"
