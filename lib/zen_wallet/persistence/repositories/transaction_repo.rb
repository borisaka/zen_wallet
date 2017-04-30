require "rom-repository"
module ZenWallet
  module Persistence
    class TransactionRepo < ROM::Repository[:transactions]
      commands :create, update: :by_pk
      relations :tx_outputs, :tx_inputs, :tx_history
      def detect(id)
        aggregate(:inputs, :outputs).by_pk(id).one
      end

      #def create(tx)
      #  command(:create, aggregate(:inputs, :outputs)).call(tx)
      #end

      def max_block_height
        root.select { [int::max(block_height).as(:block_height)] }.one.block_height || 0
      end

    end
  end
end
