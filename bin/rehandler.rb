module ZenWallet
  module Rechain
    class Future
      include EM::Deferrable

      def initialize
        handler = ReHandler.new(self)
      end
    end

    class ReHandler < RethinkDB::Handler
      # include EM::Deferrable

      def initialize(completion)
        @completion = completion
      end

      def state
        @completion.state
      end

      def value
        @completion.value
      end

      def callback
        puts "INCP"
      end

      private

      def on_open(caller)
        puts "open: #{caller}"
      end

      def on_close(caller)
        puts "close: #{caller}"
      end

      def on_wait_complete(caller)
        puts "wait: #{caller}"
      end

      def on_error(err, caller)
        @completion.fail(err)
      end

      def on_val(val, caller)
        @completion.succeed(val)
      end
    end
  end
  # def self.rehandler(completion = nil)
  #   Rechain::ReHandler.new(completion || EM::Completion.new)
  # end
end
