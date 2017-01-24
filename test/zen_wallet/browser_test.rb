require "test_helper"
require "zen_wallet/browser"
require "webmock/minitest"
module ZenWallet
  class BrowserTest < Minitest::Test
    def setup
      @browser = ZenWallet::Browser.new
      @address = "1ExQC4aJ3KfKGre59QpBCxfXHPqiXuaJFU"
    end

    def test_balance
      stub_request(:get, "https://blockexplorer.com/api/addr/#{@address}")
        .to_return(body: "{\"balance\":0.04, \"balanceSat\": 4000000}",
                   headers: { "Content-Type" => "application/json" })
      expected = { balance: 0.04, balanceSat: 4_000_000 }
      assert_equal expected, @browser.balance(@address)
    end

    def test_utxo
      body = [{ txid: "0", vout: 1, amount: 0.04, satoshis: 4_000_000 },
              { txid: "1", vout: 1, amount: 0.06, satoshis: 6_000_000 }]
      stub_request(:get, "https://blockexplorer.com/api/addr/#{@address}")
        .to_return(body: JSON.dump(body),
                   headers: { "Content-Type" => "application/json" })
      assert_equal body, @browser.balance(@address)
    end

    def test_raw_tx
      @browser.expects(:request).with(:get, "rawtx/1").returns(rawtx: "0")
      assert_equal "0", @browser.raw_tx("1")
    end

    def test_request
      stub_request(:get, "https://blockexplorer.com/api/stub")
        .to_return(body: "{\"a\":1, \"b\": 2}",
                   headers: { "Content-Type" => "application/json" })
      expected = { a: 1, b: 2 }
      # With root
      assert_equal expected, @browser.send(:request, :get, "stub")
      # Without root
      assert_equal expected, @browser.send(:request, :get, "/stub")
    end

    def test_symbolize_keys
      # Hash
      attrs = { "a" => 1, "b" => 2 }
      assert_equal({ a: 1, b: 2 }, @browser.send(:symbolize_keys, attrs))
      # Array
      attrs = [{ "a" => 1 }, { "b" => 2 }]
      assert_equal([{ a: 1 }, { b: 2 }],
                   @browser.send(:symbolize_keys, attrs))
    end
  end
end
