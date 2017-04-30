module ZenWallet
  module Rechain
    module Data
      # @api private
      module Predicates
        include Dry::Logic::Predicates
        predicate(:valid_magic?) do |network, magic|
          magic == network.magic
        end
        predicate(:msg_checksum?) do |checksum, payload|
          ChkSum[payload] == checksum
        end
        predicate(:valid_payload_size?) do |length, payload|
          payload.length == length
        end
      end

      BaseSchema = Dry::Validation.Schema do
        configure do
          # puts "We are here: #{ File.expand_path }"
          config.messages_file = File.join(__dir__, "../..", "locale", "en.yml")
          predicates(Predicates)
          config.type_specs = true
        end
      end
    end
  end
end
