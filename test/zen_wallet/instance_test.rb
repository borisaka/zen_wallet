require "test_helper"
require "zen_wallet/instance"
require "ostruct"
module ZenWallet
  class InstanceTest < Minitest::Test
    def setup
      @store = mock
      @instance = Instance.new(@store)
      @master = MoneyTree::Master.new
      MoneyTree::Master.stubs(:new).returns(@master)
      @attrs = {
        id: "id",
        encrypted_seed: "encrypted_seed",
        public_seed: @master.public_key.key,
        salt: "salt"
      }
      @wallet = Wallet.new(nil, **@attrs)
    end

    def test_wallet_if_new
      # mock_bip32_node
      SecureRandom.stubs(:hex).with(16).returns("salt")
      Utils.stubs(:encrypt)
           .with(@master.to_bip32(:private), "", "salt")
           .returns("encrypted_seed")
      @store.expects(:load_wallet).with("id").returns(nil)
      @store.expects(:create_wallet).with(is_a(Wallet))
            .returns(@attrs)
      assert_equal @wallet, @instance.wallet("id")
    end

    def test_wallet_if_exists
      @store.expects(:load_wallet).with("id").returns(**@attrs)
      assert_equal @wallet, @instance.wallet("id")
    end

    # private

    # def mock_bip32_node
    #   # master = MoneyTree.new
    #   # master.stubs(:to_bip32).with(:private).returns("bip32")
    #   # master.stubs(:public_key).returns(OpenStruct.new(key: "pubkey"))
    #   # master.stubs(:chain_code).returns(1024)
    #
    # end
  end
end
