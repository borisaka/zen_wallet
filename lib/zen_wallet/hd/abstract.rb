module ZenWallet
  module HD
    class Abstract
      extend Forwardable
      attr_reader :model, :keychain
      def_delegators :keychain, :private?, :public?, :xprv, :xpub
      include Dry::Equalizer(:model, :keychain)

      def initialize(container, **hsh)
        @model = Schema.new(**hsh)
        @container = container
        key = model.xprv || model.xpub
        @keychain = BTC::Keychain.new(extended_key: key)
      end

      def public_keychain
        keychain.public? ? keychain : keychain.public_keychain
      end
    end
  end
end
