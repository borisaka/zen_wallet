require "test_helper"
require "zen_wallet/rechain/data"
module ZenWallet::Rechain::Data
  class EncodersTest < Minitest::Test
    def setup
      @uint_type = Types::Strict::Int.encoder("C")
      @int_time = Types::Strict::Int.encoder("V")
      @time_type = Types::Strict::Time.encoder(Encoders::TimeEncoder.new(@int_time))
      # @default_encoder = Encoders::DefaultEncoder.new(Types::UInt8, "C")
      @time = Time.at(1489702057)
    end

    def test_encode
      assert_equal "\v".b, @uint_type.encode(11)
      assert_equal "\xA9\f\xCBX".b, @time_type.encode(@time)
    end

    def test_decode
      assert_equal 11, @uint_type.decode("\v".b)
      assert_equal @time, @time_type.decode("\xA9\f\xCBX".b)
    end
  end
end
