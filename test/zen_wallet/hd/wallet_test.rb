# frozen_string_literal: true
require_relative "test_helper"
require "zen_wallet/hd/wallet"
module ZenWallet
  module HD
    class WalletTest < Minitest::Test

      def setup
        @container = Dry::Container.new

      end
      # def setup
      #   @store = mock
      #   @bip32 = "xprv9s21ZrQH143K29jJ42u56Z5Ym5kqhBVgej7o3FTXB8165snaGhvdVMG21"\
      #            "gKc5EGG1ohJw3DgtXBY2ooR5vyDQkzBteQ25CQLh4SHGg6jzDy"
      #   @master_private_key = "c1cc60fa046064cc359795e22f8dc70856c576ebb8bb"\
      #                         "e3abedaf913e2e460762"
      #   @master_public_key = "0246ee6cbb9144e7d1564992e3ffc7aa9cbbecdde27f863575"\
      #                        "c57528bde24ba13e"
      #   @chain_code = "42085097655641546466663411555412059738269543587621663"\
      #                 "26662014011637816617427"
      #   @node_private_key = "3682fd4e0dbd82866c050d073be20128cded93180084c311"\
      #                       "b1f58bfd3d58fda7"
      #   @node_public_key = "02913e6126bb23cd639463414a9bd46ce2c7bf65b2bd9438249"\
      #                      "3001df8a7e79ed6"
      #   @node_address = "1GpBmTZ2tRNfpZQJKHax112z1mTsDYKVZT"
      #   @master = MoneyTree::Master.from_bip32(@bip32)
      #   # MoneyTree::Master.stubs(:new).returns(@master)
      #   @node = @master.node_for_path("m/44/0/0")
      #   @node_private_key_wif = @node.private_key.to_wif
      #   @wallet = Wallet.new(@store,
      #                        id: "id",
      #                        encrypted_seed: "encrypted_seed",
      #                        public_seed: @master.to_bip32,
      #                        salt: "salt")
      #   @a_attrs = {
      #     id: "account",
      #     order: 0,
      #     private_key: nil,
      #     public_key: @node_public_key,
      #     address: @node_address
      #   }
      #   @account = Account.new(@wallet, **@a_attrs)
      # end

      # def test_account
      #   # if account loads
      #   @wallet.expects(:load_account).with("id").returns("loaded")
      #   assert_equal "loaded", @wallet.account("id")
      #   # if account creates
      #   @wallet.expects(:load_account).with("id").returns(nil)
      #   @wallet.expects(:create_account).with("id").returns("created")
      #   assert_equal "created", @wallet.account("id")
      # end
      #
      # def test_create_account
      #   @store.expects(:next_index).with("id").returns(1)
      #   @store.expects(:persist).with(is_a(Account))
      #   assert_equal @account, @wallet.send(:create_account, "account")
      # end
      #
      # def test_load_account
      #   attrs = { id: "account", wallet_id: "id",
      #             private_key: "private_key", public_key: @account.public_key,
      #             address: "address", order: 1 }
      #   @store.stubs(:lookup).with("id", "account").returns(attrs)
      #   assert_equal @account, @wallet.send(:load_account, "account")
      # end
      #
      # # def test_account_by_address
      # #   @store.stubs(:by_wallet).with("id", address: "0").returns([@a_attrs])
      # #   assert_equal @account, @wallet.account_by_address("0")
      # # end
      #
      # def test_accounts
      #   @store.stubs(:by_wallet).with("id").returns([@a_attrs])
      #   assert_equal [@account], @wallet.accounts
      # end
      #
      # def test_unlock
      #   # Success
      #   Utils.expects(:decrypt)
      #        .with("encrypted_seed", "passphrase", "salt").returns(@bip32)
      #   unlocked = @wallet.unlock("passphrase") do |master|
      #     assert_equal @master_private_key, master.private_key.key
      #     assert_equal @chain_code.to_i, master.chain_code
      #   end
      #   assert unlocked
      #   # fail
      #   Utils.expects(:decrypt)
      #        .with("encrypted_seed", "wrong_password", "salt")
      #        .raises(OpenSSL::Cipher::CipherError)
      #   refute @wallet.unlock("wrong_password")
      # end
      #
      # def test_private_key_for
      #   @store.expects(:lookup).with("id", "account").returns(@a_attrs)
      #   @wallet.expects(:unlock).with("passphrase").yields(@master)
      #   @master.expects(:node_for_path).with("m/44/0/0").returns(@node)
      #   assert_equal @node_private_key_wif,
      #                @wallet.private_key_for("account", "passphrase")
      # end
      #
      # def test_derive_private_key
      #   @wallet.expects(:private_key_for)
      #          .with("account", "passphrase")
      #          .returns("wiff")
      #   @store.expects(:set_private_key)
      #         .with("id", "account", "wiff")
      #   assert @wallet.derive_private_key("account", "passphrase")
      # end
      #
      # def test_update_passphrase
      #   Utils.expects(:decrypt)
      #        .with("encrypted_seed", "passphrase", "salt")
      #        .returns(@bip32)
      #   SecureRandom.expects(:hex).with(16).returns("new_salt")
      #   Utils.expects(:encrypt)
      #        .with(@bip32, "new_passphrase", "new_salt")
      #        .returns("overcrypted!")
      #   @store.expects(:update_encrypted_seed)
      #         .with("id", "overcrypted!", "new_salt")
      #   @wallet.update_passphrase("passphrase", "new_passphrase")
      # end
    end
  end
end
