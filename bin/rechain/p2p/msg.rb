# frozen_string_literal: true
require "dry-container"
require "bitcoin"
require_relative "msg_parser"
require_relative "msg/abstract_msg"
require_relative "msg/ping"
require_relative "msg/pong"
require_relative "msg/verack"
require_relative "msg/version"
require_relative "msg/inv"
module ZenWallet
  module Rechain
    # Bitcoin message sending and handle
    module Msg
      def self.build_container(conn)
        container = Dry::Container.new
        container.register("connection", conn)
        container.register("logger", Logger.new(STDOUT))
        Msg::AbstractMsg.descendants.each do |kls|
          sym = Inflecto.underscore(Inflecto.demodulize(kls.name)).to_sym
          handler = kls.new(container)
          container.register(sym, handler)
        end
        container
      end
    end
  end
end
