# frozen_string_literal: true
module ZenWallet
  class Insight
    module Transformation
      module DecTXRegistry
        extend Transproc::Registry
        import Transproc::HashTransformations
        import Transproc::ArrayTransformations
        import Transproc::Coercions
        import Transproc::ClassTransformations


        def self.separate(data, left_name = nil, right_name = nil, &criteria)
          [left_name, right_name].zip((data).partition(&criteria)).to_h
        end

        def self.separate_by_addresses(data, addresses)
          separate(data, :account, :passengers) do |tx|
            addresses.include? tx[:address]
          end
        end

        def self.collect_amount(ary)
          ary&.reduce(0) { |acc, elem| acc + elem[:amount]}
        end

        def self.collect_total(tx, key)
          ins = collect_amount(tx[:calc_ins][key])
          outs = collect_amount(tx[:calc_outs][key])
          outs - ins
        end

        def self.combine_inout_for_group(hsh, key)
          hsh[:calc_ins][key] + hsh[:calc_ins][key]
        end

        def self.most_paid(ary)
          ary.max_by { |it| it[:amount] }&.fetch(:address)
        end
      end

      DecTxTransform = Class.new(Transproc::Transformer[DecTXRegistry])

      def self.TxDecorator(my_addresses, txs)
        txDecorator = DecTxTransform.define do
          map_array do
            deep_symbolize_keys
            # map_value :walletxid, t(:injector)
            # map_value :account_label, t(:injector)
            # map_value :my_addresses, t(:injector)
            copy_keys inputs: :calc_ins, outputs: :calc_outs
            map_value :calc_ins,  t(:separate_by_addresses, my_addresses)
            map_value :calc_outs, t(:separate_by_addresses, my_addresses)
            nest :total, %i(calc_ins calc_outs)

            copy_keys total: :main_address
            copy_keys total: :out_address
            map_value :main_address,
              ->(hsh){ hsh[:calc_ins][:account] + hsh[:calc_outs][:account] }
            map_value :out_address,
              ->(hsh){ hsh[:calc_ins][:passengers] + hsh[:calc_outs][:passengers] }
            copy_keys main_address: :used_addresses
            map_value :used_addresses, t(:map_array, ->(io) { io[:address] })
            map_value :main_address, t(:most_paid)
            map_value :out_address, t(:most_paid)
            map_value :total, t(:collect_total, :account)
          end
        end
        txDecorator.call(txs)
      end
    end
  end
end
