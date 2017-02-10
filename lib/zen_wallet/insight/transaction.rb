require "dry-struct"
require "zen_wallet/insight/models"
require "zen_wallet/types"
module ZenWallet
  class Insight
    class AddressBalance < Dry::Struct
      attribute :address, Types::Strict::String
      attribute :amount,  Types::Strict::Int
    end

    class Transaction < Insight::Models::Tx
      attribute :wallet, Types::PKey
      attribute :account, Types::PKey
      attribute :direction, Types::Strict::String.enum("spend", "receive")
      attribute :amount, Types::Strict::Int
      attribute :main_address, Types::Strict::String
      attribute :address_details, Types::Strict::Array.member(AddressBalance)
      attribute :peer_main_address, Types::Strict::String
      attribute :peer_amount, Types::Strict::Int
      attribute :peer_details, Types::Strict::Array.member(AddressBalance)
      # attribute :peer_label, Types::Strict::String.optional
      # attribute :amount_satoshi, Types::Strict::Int
      # attribute :balance, Types::Strict::Int
      # attribute :balance_before_tx, Types::Strict::Int
    end

    def init_fettched_tx(tx)
      peers = collect_peers(tx)
      subj = subjective(peers)
      attrs = tx.to_h.merge(subj)
      # binding.pry
      attrs.merge!(wallet: @account.model.wallet_id,
                   account: @account.model.id,
                   direction: subj[:amount].positive? ? "receive" : "spend")
      Transaction.new(attrs)
    end

    def collect_rows(rows)
      rows.group_by(&:address).map do |k, v|
        [k, v.map(&:satoshis).reduce(&:+)]
      end.to_h
    end

    def collect_peers(tx)
      gins = collect_rows(tx.inputs)
      gouts = collect_rows(tx.outputs)
      gouts.merge(gins) { |_k, rec, spent| rec - spent }
    end

    def peer_struct(peers)
      peers.sort_by { |pr| pr.last.abs }.reverse
           .map { |d| AddressBalance.new(address: d.first, amount: d.last) }
    end

    def subjective(peers)
      my, others =
        peers.partition { |addr, _| @addresses.include?(addr) }.map(&:to_h)
      amount = my.values.reduce(&:+)
      peers_amount = others.values.reduce(&:+)
      { address_details: peer_struct(my),
        main_address: my.first.first,
        amount: amount,
        peer_main_address: others.first.first,
        peer_details: peer_struct(others),
        peer_amount: peers_amount }
    end
  end
end
