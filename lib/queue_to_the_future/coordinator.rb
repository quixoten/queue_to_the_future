module QueueToTheFuture
  
  # The coordinator schedules jobs and maintains the workforce size to match. As jobs
  # get added the coordinator creates workers to complete them. The number of
  # workers created will never exceed {QueueToTheFuture::maximum_workers}.
  class Coordinator
    include Singleton
    
    # Convenience class level methods that proxy to the singleton instance
    %w/schedule queue_length workforce_size shutdown/.each do |meth|
      instance_eval("def #{meth}(*args); instance.#{meth}(*args); end")
    end
    
    # Creates the coordinator.
    # 
    # Note: This is a singleton class. To access the instance use 
    # {http://ruby-doc.org/stdlib/libdoc/singleton/rdoc/index.html Coordinator::instance}.
    def initialize
      @job_queue = Queue.new
      @workforce = []
      
      @workforce.extend(Mutex_m)
    end
    
    # The current length of the job queue
    #
    # @return [Fixnum] Length of job queue
    def queue_length
      @job_queue.length
    end
    
    # The number of workers being utilized to complete jobs.
    #
    # @return [Fixnum] Number of workers
    def workforce_size
      @workforce.size
    end
    
    # Append a QueueToTheFuture::Job to the queue.
    #
    # If there are workers available, the first available worker will be
    # woken up to perform the QueueToTheFuture::Job. If there are no
    # available workers, one will be created as long as doing so will
    # not cause the workforce to exceed QueueToTheFuture::maximum_workers.
    #
    # @param [QueueToTheFuture::Job] job
    def schedule(job)
      
      # If we can't get a lock on the @workforce then the Coordinator is most likely shutting down.
      # We want to skip creating new workers in this case.
      if @job_queue.num_waiting == 0 && @workforce.size < QueueToTheFuture.maximum_workers && @workforce.mu_try_lock
        @workforce.push Thread.new() { while job = @job_queue.shift; job.__execute__; end }
        @workforce.mu_unlock
      end
      
      @job_queue.push(job)
      
      nil
    end
    
    # Prevents more workers from being created and waits for all jobs
    # to finish. Once the jobs have completed the workers are terminated.
    #
    # To start up again just QueueToTheFuture::schedule more jobs once
    # this method returns.
    #
    # @param [true, false] force If set to true, shutdown immediately
    #   and clear the queue without waiting for any jobs to complete.
    def shutdown(force = false)
      @workforce.mu_synchronize do
        Thread.pass until @job_queue.empty? unless force
        while worker = @workforce.shift; worker.terminate; end
      end
      
      nil
    end
  end
end
