# frozen_string_literal: true
require "test_helper"
require "zen_wallet/hd/account"
require "zen_wallet/insight/client"
module ZenWallet
  module HD
    class AccountsTest < Minitest::Test
      def test_fetch_history
        account = Account.new(nil, id: "id", order: 0, private_key: "pк",
                                   public_key: "pub", address: "0")
        Insight::Client.any_instance.expects(:tx_history_all)
                       .with("0")
                       .returns([{ tx: 0 }])
        assert_equal [{ tx: 0 }], account.fetch_tx_history
      end

      def test_spend
      end
    end
  end
end
