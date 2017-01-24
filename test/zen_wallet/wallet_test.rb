require "test_helper"
require "zen_wallet/wallet"
require "money-tree"
module ZenWallet
  class WalletTest < Minitest::Test
    def setup
      @store = mock
      @bip32 = "xprv9s21ZrQH143K29jJ42u56Z5Ym5kqhBVgej7o3FTXB8165snaGhvdVMG21"\
               "gKc5EGG1ohJw3DgtXBY2ooR5vyDQkzBteQ25CQLh4SHGg6jzDy"
      @master_private_key = "c1cc60fa046064cc359795e22f8dc70856c576ebb8bb"\
                            "e3abedaf913e2e460762"
      @master_public_key = "0246ee6cbb9144e7d1564992e3ffc7aa9cbbecdde27f863575"\
                           "c57528bde24ba13e"
      @chain_code = "42085097655641546466663411555412059738269543587621663"\
                    "26662014011637816617427"
      @node_private_key = "3682fd4e0dbd82866c050d073be20128cded93180084c311"\
                          "b1f58bfd3d58fda7"
      @node_public_key = "02913e6126bb23cd639463414a9bd46ce2c7bf65b2bd943824930"\
                         "01df8a7e79ed6"
      @node_address = "1GpBmTZ2tRNfpZQJKHax112z1mTsDYKVZT"
      @master = MoneyTree::Master.from_bip32(@bip32)
      # MoneyTree::Master.stubs(:new).returns(@master)
      @node = @master.node_for_path("m/44/0/1")
      @attrs = {
        # id: "id",
        # encrypted_seed: "encrypted_seed",
        # public_key: "pubkey",
        chain_code: 1024
      }
      @wallet = Wallet.new(@store,
                           id: "id",
                           encrypted_seed: "encrypted_seed",
                           public_seed: @master.to_bip32,
                           salt: "salt")
      @account = Account.new(@wallet,
                             id: "account",
                             private_key: nil,
                             public_key: @node_public_key,
                             address: @node_address)
      # @master = mock
      # @master.stubs(:private_key).returns(OpenStruct.new(key: "private_key"))
      # @master.stubs(:public_key).returns(OpenStruct.new(key: "public_key"))
      # @master.stubs(:node_for_path).with("m/1").returns(@master)
    end

    def test_account
      # if account loads
      @wallet.expects(:load_account).with("id").returns("loaded")
      assert_equal "loaded", @wallet.account("id")
      # if account creates
      @wallet.expects(:load_account).with("id").returns(nil)
      @wallet.expects(:create_account).with("id").returns("created")
      assert_equal "created", @wallet.account("id")
    end

    def test_create_account
      @store.stubs(:next_account_index).with("id").returns(1)
      @store.expects(:create_account).with(is_a(Account))
      assert_equal @account, @wallet.send(:create_account, "account")
    end

    def test_load_account
      attrs = { id: "account", wallet_id: "id",
                private_key: "private_key", public_key: @account.public_key,
                address: "address", order: 1 }
      @store.stubs(:load_account).with("id", "account").returns(attrs)
      assert_equal @account, @wallet.send(:load_account, "account")
    end

    def test_unlock
      Utils.expects(:decrypt)
           .with("encrypted_seed", "passphrase", "salt").returns(@bip32)
      @wallet.unlock("passphrase") do |master|
        assert_equal @master_private_key, master.private_key.key
        assert_equal @chain_code.to_i, master.chain_code
      end
    end

    def test_derive_private_key
      @store.expects(:load_account).with("id", "account").returns(order: 1)
      @wallet.expects(:unlock).with("passphrase").yields(@master)
      @master.expects(:node_for_path).with("m/44/0/1").returns(@node)
      @store.expects(:set_account_private_key)
            .with("id", "account", @node_private_key)
      @wallet.derive_private_key("account", passphrase: "passphrase")
    end
    #
    # def test_update_password
    # end
    #
    # def test_utxos
    # end
    #
    # def test_balance
    # end
    #
    # def test_send_money
    # end
  end
end
