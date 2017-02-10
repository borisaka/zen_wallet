# frozen_string_literal: true
require "bitcoin"
Bitcoin.network = :testnet3
# require "btcruby"
module ZenWallet
  module Bt
    def self.pay
      include Bitcoin::Builder
      prev_hash = "f85c89a6b279b9fbfaddcd5be85f9c353b0537d81770b92a63d2037a3db30b9a"
      prev_out_index = 0
    end
  end
end
