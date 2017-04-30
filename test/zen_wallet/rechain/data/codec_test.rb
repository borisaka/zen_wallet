require "test_helper"
require "zen_wallet/rechain/data"
module ZenWallet::Rechain::Data
  class CodecTest < Minitest::Test
    FakeType = Types::String.constrained(eql: "†∑œ")
    def test_encode
      # fail MissingCode
      assert_raises(Codec::MissingCode) { Codec.encode(FakeType, "†∑œ") }
      # fail WrongValue
      assert_raises(Dry::Types::ConstraintError) do
        Codec.encode(Types::UInt8, 0x100)
      end
      # Success
      assert_equal "\v".b, Codec.encode(Types::UInt8, 11)
    end

    def test_decode
      # fail MissingCode
      assert_raises(Codec::MissingCode) { Codec.decode(FakeType, "†∑œ") }
      # Success
      assert_equal 11, Codec.decode(Types::UInt8, "\v".b)
    end
  end
end
