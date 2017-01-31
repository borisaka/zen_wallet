# frozen_string_literal: true
require "test_helper"
require "webmock/minitest"
require "faker"
require "zen_wallet/insight/client"
module ZenWallet
  module Insight
    class ClientTest < Minitest::Test
      def setup
        bitcore_link = "https://#{Faker::Internet.domain_name}"
        @client = Client.new(bitcore_link)
        @address = "1ExQC4aJ3KfKGre59QpBCxfXHPqiXuaJFU"
        @base_url = "#{bitcore_link}/api"
      end

      def test_get
        stub_request(:get, "#{@base_url}/stub")
          .to_return(body: "{\"a\":1, \"b\": 2}",
                     headers: { "Content-Type" => "application/json" })
        expected = { a: 1, b: 2 }
        assert_equal expected, @client.send(:get, "stub")
      end

      def test_post
        request_body = SecureRandom.hex
        result = { body: request_body }
        stub_request(:post, "#{@base_url}/stub")
          .with(body: request_body)
          .to_return(body: JSON.dump(result),
                     headers: { "Content-Type" => "application/json" })
        assert_equal result, @client.send(:post, "stub", request_body)
      end

      def test_balance
        stub_request(:get, "#{@base_url}/addr/#{@address}")
          .to_return(body: "{\"balance\":0.04, \"balanceSat\": 4000000}",
                     headers: { "Content-Type" => "application/json" })
        expected = { balance: 0.04, balanceSat: 4_000_000 }
        assert_equal expected, @client.balance(@address)
      end

      def test_tx_history
        txs = { txs: "ALL" }
        url = "#{@base_url}/addrs/#{@address}/txs?from=1&to=10"
        stub_request(:get, url).to_return(body: JSON.dump(txs))
        assert_equal txs, @client.tx_history(@address, 1, 10)
      end

      def test_tx_history_all
        @client.expects(:tx_history)
               .with("0", 0, 10)
               .returns(totalItems: 26, from: 0, to: 10, items: [0])
        Mappers::TxMapper.any_instance.expects(:call).with([0]).returns([0])
        @client.expects(:tx_history)
               .with("0", 10, 20)
               .returns(totalItems: 26, from: 10, to: 20, items: [1])
        Mappers::TxMapper.any_instance.expects(:call).with([1]).returns([1])
        @client.expects(:tx_history)
               .with("0", 20, 26)
               .returns(totalItems: 26, from: 20, to: 26, items: [2])
        Mappers::TxMapper.any_instance.expects(:call).with([2]).returns([2])
        assert_equal [0, 1, 2], @client.tx_history_all("0")
      end

      # def test_utxo
      #   body = [{ txid: "0", vout: 1, amount: 0.04, satoshis: 4_000_000 },
      #           { txid: "1", vout: 1, amount: 0.06, satoshis: 6_000_000 }]
      #   stub_request(:get, "https://blockexplorer.com/api/addr/#{@address}")
      #     .to_return(body: JSON.dump(body),
      #                headers: { "Content-Type" => "application/json" })
      #   assert_equal body, @client.balance(@address)
      # end
      #
      # def test_raw_tx
      #   @client.expects(:request).with(:get, "rawtx/1").returns(rawtx: "0")
      #   assert_equal "0", @client.raw_tx("1")
      # end


      #
      # def test_symbolize_keys
      #   # Hash
      #   attrs = { "a" => 1, "b" => 2 }
      #   assert_equal({ a: 1, b: 2 }, @client.send(:symbolize_keys, attrs))
      #   # Array
      #   attrs = [{ "a" => 1 }, { "b" => 2 }]
      #   assert_equal([{ a: 1 }, { b: 2 }],
      #                @client.send(:symbolize_keys, attrs))
      # end
    end
  end
end
