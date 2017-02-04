# frozen_string_literal: true
module ZenWallet
  module Persistence
    # Persist of HD wallet with basic seed encryption
    class Wallets < Store
      def persist(wallet)
        attrs = { id: wallet.id, encrypted_seed: wallet.encrypted_seed,
                  salt: wallet.salt, public_seed: wallet.public_seed }
        dataset.insert(**attrs) && attrs
      end

      def lookup(id)
        dataset.where(id: id).first
      end

      def update_encrypted_seed(id, new_encrypted_seed, new_salt)
        dataset.where(id: id)
               .update(encrypted_seed: new_encrypted_seed, salt: new_salt)
      end
    end
  end
end
