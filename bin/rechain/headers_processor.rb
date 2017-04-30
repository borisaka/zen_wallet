module ZenWallet
  module Rechain
    # Process headers response
    class HeadersProcessor
      MAX_LOCATORS = 500
      CHUNK_SIZE = 200
      WrongBlockOrder = Class.new(StandardError)
      def initialize(container)
        @genesis_header = container
                          .resolve("bitcoin_network")
                          .genesis_block_header
        @logger = container.resolve("logger")
        @store = container.resolve("block_store")
        # @tasky = container.resolve("task_master")
      end

      # Find block hash locators in db or return array with genesis
      #   block header id
      # see https://bitcoin.org/en/developer-reference#getheaders
      def locators
        persisted = @store.last_ids(MAX_LOCATORS) || [@genesis_header.block_id]
        persisted.empty? ? [@genesis_header.block_id] : persisted
      end

      # Process array of headers
      def process(headers)
        headers.each_slice(100).each { |chunk| process_chunk(chunk) }
      end

      # Process CHUNK_SIZE of block headers what need to be processed
      #   persist if every headers ok and going in right order
      def process_chunk(headers)
        @logger.debug("detect pervious")
        first_header = @store.detect(headers[0].previous_block_id)
        processed = [first_header || serialize(@genesis_header)]
        headers.each do |header|
          validate_order(processed[-1], header)
          height = processed[-1]["height"] + 1
          processed << serialize(header).merge("height" => height)
        end
        @store.append(processed[1..-1])
      end

      # def handle(payload)
      #   # @logger.debug("PAYLOAD: #{payload}")
      #   buf = StringIO.new(payload)
      #   count = Bitcoin::Protocol.unpack_var_int_from_io(buf)
      #   @logger.debug("fetched count blocks: #{count}")
      #   correct_header = lambda do
      #     new_header.previous_block_id == headers[-1][:id]
      #   end
      #   last_header.callback do |last_header|
      #     @logger.debug "Last header: #{last_header}"
      #     headers = [*last_header]
      #     count.times do |i|
      #       break if buf.eof?
      #       @logger.debug("Current headers length: #{headers.length}")
      #       new_header = BTC::BlockHeader.new(data: buf.read(81))
      #       raise "YOU WRONG BLOCKS" unless correct_header.call
      #       headers <<  persist(new_header, headers[-1])
      #     end
      #   end
      # end


      # def fetch_locators
      #   @logger.debug("Load hash locators")
      #   completion = EM::Completion.new
      #   @store.last_ids(500).callback do |ids|
      #     @logger.debug ids.empty? ? "Sending genesis" : "Locators blocks: #{ids}"
      #     current = ids.empty? ? [@genesis_header.block_id] : ids
      #     completion.succeed(current)
      #   end
      #   completion
      # end

      private

      def validate_order(h0, h1)
        return true if h0["id"] == h1.previous_block_id
        msg = "await: #{h0["id"]} handled: #{h1.previous_block_id}"
        raise WrongBlockOrder, msg
      end

      def last_header
        cpl = EM::Completion.new
        @store.last.callback do |lst|
          cpl.succeed lst.empty? ? [serialize(@genesis_header)] : lst
        end
        cpl
      end

      def persist(new_header, previous)
        @logger.info("Setting #{new_header.block_id} height "\
                    "#{previous["height"] + 1}")
        new_header.height = previous["height"] + 1
        serialized = serialize(new_header)
        @logger.debug("Try to persist: #{serialized}")
        @store.append([serialized])
          .callback { |result| @logger.debug("Persist: #{result}") }
        true
      end

      def serialize(header)
        { "id" => header.block_id,
          "previous_id" => header.previous_block_id,
          "time" => header.time,
          "height" => header.height,
          "version" => header.version,
          "bits" => header.bits,
          "nonce" => header.nonce,
          "state" => "header"
        }
      end
    end
  end
end
