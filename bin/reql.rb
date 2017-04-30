class CompletionHandler < RethinkDB::Handler
  # include EM::Deferrable
  attr_reader :future
  def initialize(future)
    @future = future
    # @future.value = []
    @stopped = false
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end

  # def handle(m, args, caller)
  #   logger.debug("Handle #{m} ... #{args}")
  #   logger.debug("Super handles: #{super}")
  # end
  #   @future.succeed(super)
  # rescue => e
  #   @future.fail(e)
  #   # if !stopped?
  #   #   mar = method(m).arity
  #   #   if mar == args.size
  #   #     send(m, *args)
  #   #   elsif mar == 0
  #   #     send(m)
  #   #   else
  #   #     send(m, *args, caller)
  #   #   end
  #   # end
  # end


  def on_open(caller)
    # logger.debug "open: #{caller}"
  end

  def on_close(caller)
    # logger.debug "close: #{caller}"
    @future.succeed(@value || []) #if @value
  end

  def on_wait_complete(caller)
    # logger.debug "wait: #{caller}"
  end

  def on_array(arr, caller)
    # logger.debug("handle arrat #{arr}")
    super
  end
    # @future.succeed(arr)
    # if method(:on_atom).owner != Handler
    #   handle(:on_atom, [arr], caller)
    # else
    #   arr.each {|x|
    #     break if stopped?
    #     handle(:on_stream_val, [x], caller)
    #   }
    # end
  # end
  #
  def on_atom(val, caller)
    # logger.debug("Handle atom: #{val}")
    handle(:on_val, [val], caller)
  end
  #
  def on_stream_val(val, caller)
  #  logger.debug("Streaming #{val}")
    @value ||= []
    @value << val
    # @future.change_state(:streaming, val)
    # puts "STT"
    # handle(:on_val, [val], caller)
  end

  def on_error(err, caller)
    logger.error("#{err}")
    @future.fail(err)
  end

  def on_val(val, caller)
    # logger.debug("returned value #{val}")
    @value = val
    # @future.succeed(val)
  end
end

module RethinkDB
  class RQL

    def run_future(conn, future = nil)
      future ||= EM::Completion.new
      em_run(conn, CompletionHandler.new(future))
        .instance_variable_get("@handler")
        .future
    end
  end
end
