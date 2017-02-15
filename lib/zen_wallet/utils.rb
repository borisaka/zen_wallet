module ZenWallet
  class SimpleCache
    DEFAULT_EXPIRATION = 300
    class Expirable
      extend Forwardable
      include Comparable
      # def_delegator :expires, :<=> , :<,  :Ω<=
      def initialize(expires, value, key)
        @expires, @value, @key = expires, value, key
      end
    end

    def initialize
      @store = SortedSet.new
      @hashstore = Hash.new
    end

    def store(key, value, expires = DEFAULT_EXPIRATION)
      @hashstore[key] = value
      @store << [expires, value, key]
    end
  end
end
