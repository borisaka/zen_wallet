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

        def self.calc_details(hsh)
          hsh.merge(
            account_detail: {
              inputs: hsh[:calc_ins][:account],
              outputs: hsh[:calc_outs][:account]
            },
            passengers_outs: hsh[:calc_outs][:passengers]
          )
        end

        def self.calc_out_address(hsh)
          receive = hsh[:total].positive?
          addr = receive ? hsh[:main_address] : most_paid(hsh[:passengers_outs])
          hsh.merge(out_address: addr)
        end

        def self.fetch_addresses(addrs)
          addrs.map { |hsh| hsh[:address] }.uniq
        end
      end

      DecTxTransform = Class.new(Transproc::Transformer[DecTXRegistry])

      def self.TxDecorator(wallet, account, my_addresses, txs)
        txDecorator = DecTxTransform.define do
          map_array ->(tx) { TxTransform.call(tx) }
          map_array do
            deep_symbolize_keys
            copy_keys inputs: :calc_ins, outputs: :calc_outs
            map_value :calc_ins,  t(:separate_by_addresses, my_addresses)
            map_value :calc_outs, t(:separate_by_addresses, my_addresses)
            calc_details
            nest :total, %i(calc_ins calc_outs)
            copy_keys total: :main_address
            copy_keys total: :out_address
            map_value :main_address,
              ->(hsh){ hsh[:calc_ins][:account] + hsh[:calc_outs][:account] }
            copy_keys main_address: :used_addresses
            map_value :used_addresses, t(:fetch_addresses)
            map_value :main_address, t(:most_paid)
            map_value :total, t(:collect_total, :account)
            calc_out_address
            reject_keys %i(passengers_outs)
            constructor_inject Models::AccountTx
          end
        end
        mapped = txs.map { |tx| tx.merge(wallet: wallet, account: account) }
        txDecorator.call(mapped)
      end
    end
  end
end
