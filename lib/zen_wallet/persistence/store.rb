# frozen_string_literal: true
require "inflecto"
module ZenWallet
  module Persistence
    # Base store
    class Store
      attr_reader :dataset
      def initialize(dataset, *_args)
        @dataset = dataset
      end
    end
  end
end
