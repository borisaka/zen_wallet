# frozen_string_literal: true
require "test_helper"
require "zen_wallet/hd/account"
# require "zen_wallet/insight/client"
module ZenWallet
  module HD
    class AccountsTest < Minitest::Test
      include WalletModelMixin
      include AccModelMixin
      include AddressMixin

      def setup
        super
        @address_repo = mock
        @keychain = BTC::Keychain.new(xpub: AccConstants::Balance::XPUB)
        @model = @acc_balance_model
        @account = Account.new(@model, @address_repo)
        @finders = [@model.wallet_id, @model.index]
        # @address_repo.stubs(:find_or_create).with()
      end

      def test_receive_address
        @address_repo.stubs(:gap_size).with(*@finders).returns(0)
        @address_repo.stubs(:next_index).with(*@finders).returns(0)
        @address_repo.stubs(:find_or_create)
                     .with(@addresses_models.first)
                     .returns(@addresses_models.first)
        # if empty
        assert_equal @addresses_models.first, @account.receive_address(false)
        assert_equal @addresses_models.first, @account.receive_address(true)
        # if not full and not force
        @address_repo.stubs(:gap_size).with(*@finders).returns(10)
        @address_repo.stubs(:next_index).with(*@finders).returns(10)
        @address_repo.stubs(:find_or_create)
                     .with(@addresses_models[10])
                     .returns(@addresses_models[10])
        assert_equal @addresses_models[10], @account.receive_address(true)
        @address_repo.stubs(:unused_recvs).with(*@finders)
                     .returns(@addresses_models[0..9].reverse)
        assert_equal @addresses_models[9], @account.receive_address(false)
        # if full gap limit
        @address_repo.stubs(:gap_size).with(*@finders).returns(20)
        @address_repo.stubs(:next_index).with(*@finders).returns(20)
        assert_raises(Account::GapLimitIsOver) do
          @account.receive_address(true)
        end
        @address_repo.stubs(:unused_recvs).with(*@finders)
                     .returns(@addresses_models.reverse)
        assert_equal @addresses_models[19], @account.receive_address(false)
      end

      def test_discovery
        @address_repo.expects(:gap_size).with(*@finders)
                     .returns(*0..20).times(21)
        @address_repo.expects(:next_index).with(*@finders)
          .returns(*0..19).times(20)
        @address_repo.expects(:find_or_create)
                     .with(any_of(*@addresses_models)).times(20)
                     .returns(*@addresses_models)
        @account.discovery
      end
    end
  end
end
