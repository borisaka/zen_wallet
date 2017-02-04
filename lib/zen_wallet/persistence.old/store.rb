# frozen_string_literal: true
require "zen_wallet/introspections"
module ZenWallet
  module Persistence
    # Base store
    class Store
      include ZenWallet::Introspections::TableFinder
      attr_reader :dataset
      def initialize(container)
        @dataset = container.resolve("main.db")[table]
      end
    end
  end
end
