# frozen_string_literal: true
require "logger"
require "dry/matcher/either_matcher"
require_relative "network"
require_relative "msg_parser"
require_relative "msg"
module ZenWallet
  module Rechain
    # P2P client socket connection
    class Connection
      # Wait for some message or object from peer
      UnsupportedMessage = Class.new(StandardError)
      SEEDS = %w(bitseed.xf2.org dnsseed.bluematt.me seed.bitcoin.sipa.be
                 dnsseed.bitcoin.dashjr.org seed.bitcoinstats.com).freeze
      TESTNET_SEEDS = %w(testnet-seed.bitcoin.jonasschnelli.ch
                         seed.tbtc.petertodd.org testnet-seed.bluematt.me
                         testnet-seed.bitcoin.schildbach.d).freeze
      attr_reader :network, :host, :port, :waiters

      def self.dns_seeds
        TESTNET_SEEDS
        # @network.testnet? ? TESTNET_SEEDS : SEEDS
      end

      def self.connect_random_from_dns
        logger = Logger.new(STDOUT)
        dns = dns_seeds.sample
        host = Resolv::DNS.new.getaddresses(dns).map(&:to_s).sample
        logger.info("connecting to #{host}... host resolved by #{dns}")
        new(host, Bitcoin.network[:default_port])
      end

      def initialize(host, port, network = Network.testnet)
        @host = host
        @port = port
        @socket = TCPSocket.new(host, port)
        @network = network
        @container = Msg.build_container(self)
        gen_and_send_msg(:version)
        wait(:verack)
      end

      def gen_and_send_msg(msg, *argv)
        @socket.write(lookup_handler(msg).generate(*argv))
      end

      def wait(msg, &blk)
        @wait = msg
        blk ||= ->(_) { @wait.nil? ? :fulfilled : :processing }
        result = receive until %i(fulfilled canceled).include?(blk.call(result))
      end

      def receive
        either_msg = MsgParser.read_and_parse(@network, @socket)
        Dry::Matcher::EitherMatcher.call(either_msg) do |m|
          m.success do |msg|
            handle(msg)
          end
          m.failure do |reason|
            logger.error("Could nod parse command: #{reason}")
          end
        end
      end

      private

      def lookup_handler(cmd)
        @container.resolve(cmd)
      end

      def handle(msg)
        logger.debug("Handling #{msg.cmd} with #{msg.payload}")
        @wait = nil if @wait == msg.cmd
        handler = lookup_handler(msg.cmd)
        logger.warn("Handler for #{msg.cmd} is not set!") unless handler
        handler&.handle(msg.payload)
      end

      def logger
        @logger ||= Logger.new(STDOUT)
      end
    end
  end
end
