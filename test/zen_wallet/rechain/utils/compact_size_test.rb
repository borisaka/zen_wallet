# frozen_string_literal: true
require "test_helper"
require "zen_wallet/rechain/utils"
module ZenWallet::Rechain::Utils
  class CompactSizeTest < Minitest::Test

    def setup
      @c_val = SecureRandom.hex(10)
      @c_pkt = [20, @c_val].pack("Ca*")
      @v_val = SecureRandom.hex(1024)
      @v_pkt = [0xFD, 2048, @v_val].pack("Cva*")
    end

    def test_pack_var_int
      # raises if integer > 0xFFFFFFFFFFFFFFFF
      assert_raises CompactSize::LenghtTooLarge do
        CompactSize.pack_var_int(0xFFFFFFFFFFFFFFFF + 1)
      end
      # Packs 8bit simply
      assert_equal "\x17", CompactSize.pack_var_int(23)
      # Packs with 0xFE label
      assert_equal ["\xFE\xA0\x86\x01\x00"].pack("a*"),
                   CompactSize.pack_var_int(100_000)
    end

    def test_extract_string
      # Extracts with 8bit len
      assert_equal @c_val, CompactSize.extract_string(@c_pkt)
      # Extracts with 0xFD label
      assert_equal @v_val, CompactSize.extract_string(@v_pkt)
    end

    def test_pack_string
      # Packs without label
      assert_equal @c_pkt, CompactSize.pack_string(@c_val)
      # Packs with 0xFD label
      assert_equal @v_pkt, CompactSize.pack_string(@v_val)
    end
  end
end
