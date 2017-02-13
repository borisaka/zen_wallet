# frozen_string_literal: true
module ZenWallet
  module Bitcoin
    # Module to optimal select UTXO and prepare them to signification
    module InputsHelper
      DUST_CHANGE = 1000

      module_function

      Input = Struct.new(:utxo, :key)
      PreparedInputs = Struct.new(:inputs, :change)
      def prepare_inputs(utxo, amount, &key_provider)
        selected = select(utxo, amount)
        inputs = appen_keys(selected, &key_provider)
        inputs_total = selected.map(&:amount).reduce(:+)
        change = inputs_total - amount
        PreparedInputs.new(inputs, change > DUST_CHANGE ? change : 0)
      end

      def appen_keys(utxo, &key_provider)
        addr_keys = key_provider[utxo.map(&:address).uniq]
        utxo.map do |u|
          key = addr_keys.detect { |ak| ak.address == u.address }.key
          Input.new(u, key)
        end
      end

      def select(utxo, amount)
        if utxo.any? { |u| u.confirmations.zero? }
          confirmed = utxo.select { |u| u.confirmations.positive? }
          return collect(confirmed, amount) if enough?(confirmed, amount)
        end
        collect(utxo, amount)
      end

      def collect(utxo, amount)
        same = same_amount(utxo, amount)
        return [same] if same
        less, more = utxo.partition { |u| u.amount < amount }
        if enough?(less, amount)
          maximal = less.max_by(&:amount)
          [maximal, *collect(utxo - [maximal], amount - maximal.amount)]
        else
          [more.min_by(&:amount)]
        end
      end

      # If found without change perfect
      def same_amount(utxo, amount)
        utxo.detect do |u|
          (u.amount..(u.amount + DUST_CHANGE)).cover?(amount)
        end
      end

      def enough?(utxo, amount)
        utxo.map(&:amount).reduce(:+) >= amount unless utxo.empty?
      end
    end
  end
end
