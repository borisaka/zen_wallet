require "test_helper"
require "zen_wallet/hd/account/history"
require "zen_wallet/insight"

module ZenWallet
  module HD
    class Account
      class HistoryTest < Minitest::Test
        def setup
          @insight = mock
          @insight.responds_like_instance_of(Insight)
        end

        def test_enum
          steps = History::FIB[0...10] + [50, 50]
          steps.each_with_index do |step, idx|
            @insight.allow(:transactions)
          end
        end
      end
    end
  end
end
