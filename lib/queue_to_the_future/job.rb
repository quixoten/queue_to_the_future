module QueueToTheFuture
  class Job
    (instance_methods - %w[__send__ __id__ object_id inspect]).each { |meth| undef_method(meth) }
    
    def initialize(*args, &block)
      @args   = args
      @block  = block
    end
    
    def __execute__
      @result = @block.call(*@args)
    end
    
    def method_missing(*args, &block)
      Thread.pass while !defined?(@result)
      @result.send(*args, &block)
    end
  end
end