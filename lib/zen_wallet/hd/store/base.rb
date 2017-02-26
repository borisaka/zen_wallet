module ZenWallet
  module HD
    # Base class
    class StoreBase
      def initialize(conn, account)
        @conn = conn
        @account = account
      end

      private

      def wid
        @account.wallet_id
      end

      def idx
        @account.index
      end
    end
  end
end
