# frozen_string_literal: true
require "dry-initializer"
module ZenWallet
  module HD
    class Address
      def initialize(container, account, model)
        @repo = container.resolve("address_repo")
        @model = model
        @account = account
      end

    end
  end
end
