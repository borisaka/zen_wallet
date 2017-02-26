# frozen_string_literal: true
module ZenWallet
  module Bitcoin
    # Module to optimal select UTXO and prepare them to signification
    module InputsHelper
      DUST_CHANGE = 1000

      module_function

      # Simle structs to communicate
      Input = Struct.new(:utxo, :key)
      PreparedInputs = Struct.new(:inputs, :change)

      # Collect optimal UTXO and aggregate with private keys
      # @param utxo [Array<CommonStructs::Utxo>]
      # @param amount [Integer] total amount (including fees)
      # @yield [Array<String>] array of addreses to provide private keys
      # @api public
      def prepare_inputs(utxo, amount, &key_provider)
        selected = select(utxo, amount)
        inputs = appen_keys(selected, &key_provider)
        inputs_total = selected.map(&:amount).reduce(:+)
        change = inputs_total - amount
        PreparedInputs.new(inputs, change > DUST_CHANGE ? change : 0)
      end

      # @api private
      def appen_keys(utxo, &key_provider)
        addr_keys = key_provider[utxo.map(&:address).uniq]
        utxo.map do |u|
          key = addr_keys.detect { |ak| ak.address == u.address }.key
          Input.new(u, key)
        end
      end

      # @api private
      def select(utxo, amount)
        confirmed = utxo.select(&:confirmed)
        if !confirmed.empty? && enough?(confirmed, amount)
          return collect(confirmed, amount)
        end
        collect(utxo, amount)
      end

      # @api private
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

      # @api private
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
