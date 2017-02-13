# frozen_string_literal: true
require "btcruby"
module ZenWallet
  module B
    extend BTC
    def self.pay
      # 1b2e3d913f08906d448e185ec777aaecf90b371aee39f790387f91859cf5840c
      peer = BTC::PublicKeyAddress.parse("mkRbQCWatqT3gpbFAofASJuGExxyg6aCmD").script
      change_addr = BTC::PublicKeyAddress.parse("mqyY6uXNy2gzipamqbd56k2bVB6QutTGTW").script
      # address = "n4SnJNuizfPcB3r3b4CwZtirBXFqhkMrzM"
      prev_tx_id = "f85c89a6b279b9fbfaddcd5be85f9c353b0537d81770b92a6"\
                   "3d2037a3db30b9a"
      output_sig = "76a914fb80e2e2a7a01a1275e9e6e6fa6ea858ba0d7a4a88ac"
      output_script = BTC::Script.new(data: BTC.from_hex(output_sig))
      tx = BTC::Transaction.new
      tx.add_input BTC::TransactionInput
                   .new(previous_id: prev_tx_id, previous_index: 0)
      tx.add_output BTC::TransactionOutput.new(value: 40_000_000, script: peer)
      tx.add_output BTC::TransactionOutput
                    .new(value: 49_900_000, script: change_addr)

      key = BTC::Key
           .new(wif: "L3cYGxBcidT6iL3nWUgL72YFdrzUyhsMKKaE31hXiRjk2ebQ4SaV")
      ht = BTC::SIGHASH_ALL
      sighash = tx.signature_hash(input_index: 0, output_script:  output_script,
                                  hash_type: ht)

       tx.inputs[0].signature_script =
         BTC::Script.new << (key.ecdsa_signature(sighash) + \
                            BTC::WireFormat.encode_uint8(ht)) << \
                            key.public_key
       puts tx.data
       return tx.to_hex
    end
  end
end
