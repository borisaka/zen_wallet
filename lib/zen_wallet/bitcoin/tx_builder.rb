module ZenWallet
  module Bitcoin
    # Custom builder vlass
    class TxBuilder
      def initialize
        @outputs = []
        @change_address = nil
        @change_output = nil
        @inputs = []
      end

      # @param output_info [CommonStructs::AddressAmount]
      def output(output_info)
        @outputs << build_output(output_info)
      end

      def input(prepared_input)
        @inputs << prepared_input
      end

      def build
        @tx = BTC::Transaction.new
        pair = Struct.new(:txin, :index)
        @stored_with_index = []
        @inputs.each_with_index do |txin, index|
          @tx.add_input(build_input(txin))
          @stored_with_index << pair.new(txin, index)
        end
        @outputs.each { |txout| @tx.add_output(txout) }
        @stored_with_index.each do |ut|
          sign_input(ut.txin, ut.index)
        end
        @tx.to_hex
      end

      private

      def sign_input(txin, index)
        # index = @tx.inputs.index(input)
        htype = BTC::SIGHASH_ALL
        output_script = BTC::Script.new(data: BTC.from_hex(txin.utxo.script))
        sighash = @tx.signature_hash(input_index: index,
                                     output_script:  output_script,
                                     hash_type: htype)

        @tx.inputs[index].signature_script =
          BTC::Script.new << (txin.key.ecdsa_signature(sighash) + \
          BTC::WireFormat.encode_uint8(htype)) << txin.key.public_key
      end

      def build_output(output_info)
        script = BTC::Address.parse(output_info.address).script
        BTC::TransactionOutput.new(value: output_info.amount, script: script)
      end

      def build_input(info)
        u = info.utxo
        BTC::TransactionInput.new(previous_id: u.txid, previous_index: u.vout)
        # hash_typev = BTC::SIGHASH_ALL
      end
    end
  end
end
