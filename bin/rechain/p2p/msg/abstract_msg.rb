module ZenWallet
  module Rechain
    module Msg
      class AbstractMsg
        attr_reader :connection, :logger

        def self.inherited(subclass)
          @descendants ||= []
          @descendants << subclass
        end

        def self.descendants
          @descendants
        end

        def initialize(container)
          @connection = container.resolve("connection")
          @logger = container.resolve("logger")
        end

        def generate(*argv)
          raise UnimplementedError
        end

        def handle(payload)
          raise UnimplementedError
        end
      end
    end
  end
end
