module ZenWallet
  module HD
    class Account
      # @api private
      # Helper class to manage account address
      class Registry
        # BIP44 specified limit
        GAP_LIMIT = 20
        EXTERNAL_CHAIN = 0
        INTERNAL_CHAIN = 1
        # BIP44 spec violation
        class InvalidChainError < StandardError
          def message
            "Chain must be either ecternal: #{EXTERNAL_CHAIN} "\
              "or internal #{INTERNAL_CHAIN}"
          end
        end
        # @param accont [Models::Account] account model
        # @param repo [Persistence::AddressRepo] repository of address
        # @param network [::BTC::Network] current network
        # @param keychain [::BTC::Keychain] keychain
        def initialize(account, repo, network, keychain)
          @account = account
          @repo = repo
          @network = network
          # Only public keychain needed
          @keychain = keychain.public_keychain
        end

        # Pregenerate all GAP limited addresses for possible discovery
        def fill_gap_limit
          [EXTERNAL_CHAIN, INTERNAL_CHAIN].each do |chain|
            gap_size = @repo.count(wid, idx, chain, has_txs: false)
            gap_size.upto(GAP_LIMIT - 1) do
              index = @repo.last_idx(wid, idx, chain)&.+(1)
              index ||= 0
              create_address(chain, index)
            end
          end
        end

        # Select unused address for chain. if possible not requested
        def free_address(chain)
          @repo.free_address(wid, idx, chain)
        end

        # Mark address as requested unless alreadt
        def ensure_requested_mark(addrs)
          @repo.update_addresses(addrs, requested: true)
        end

        # Mark address as used unless alreadt
        def ensure_has_txs_mark(addr)
          @repo.update_addresses(addr, has_txs: true)
        end

        # pluck array of addresses strings
        # @return [Array<Sring>]
        def pluck_addresses(offset: 0, **filters)
          @repo.pluck_address(wid, idx, offset, **filters)
        end

        private

        # Generate ant persist address with next index
        def create_address(chain, index)
          addr = gen_address(chain, index)
          model = Models::Address.new(
            wallet_id: wid, account_index: idx, chain: chain, index: index,
            address: addr, has_txs: false, requested: false
          )
          @repo.create(model)
          true
        end

        def gen_address(chain, index)
          pubkey =
            case chain
            when EXTERNAL_CHAIN
              @keychain.bip44_external_keychain.derived_key(index)
            when INTERNAL_CHAIN
              @keychain.bip44_internal_keychain.derived_key(index)
            else raise InvalidChainError
            end
          pubkey.address(network: @network).to_s
        end

        def wid
          @account.wallet_id
        end

        def idx
          @account.index
        end
      end
    end
  end
end
