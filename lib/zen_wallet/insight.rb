require "dry-struct"
require_relative "insight/client"
module ZenWallet
  module Insight
    def self.client
      Client.new
    end
  end
end
