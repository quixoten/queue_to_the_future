module QueueToTheFuture
  # A proxy object for the future return value of a block.
  class Job
    instance_methods.each { |meth| undef_method(meth) unless %w(__send__ __id__ object_id inspect).include?(meth.to_s) }
    
    # Creates a job and schedules it by calling {Coordinator#schedule}.
    #
    # @param [List] *args The list of arguments to pass to the given block
    # @param [Proc] &block The block to be executed
    def initialize(*args, &block)
      @args   = args
      @block  = block
      Coordinator::instance.schedule(self)
    end
    
    # Execute the job.
    #
    # This is called by the worker the job gets assigned to.
    # @return [nil]
    def __execute__
      @result = @block.call(*@args); nil
      
      # Prevent multiple executions
      def __execute__; @result; end
    end
    
    # Allows the job to behave as the return value of the block.
    #
    # Accessing any method on the job will cause code to block
    # until the job is completed.
    def method_missing(*args, &block)
      Thread.pass until defined?(@result)
      @result.send(*args, &block)
    end
  end
end