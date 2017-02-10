require "dry-types"
module ZenWallet
  module Types
    include Dry::Types.module
    PKey = Strict::String.constrained(max_size: 50)
    # for deprecated accounts
    HDIndex = Strict::Int.constrained(gteq: -1)
    HDChange = Strict::Int.constrained(included_in: 0..1)
  end
end
