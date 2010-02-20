module QueueToTheFuture
  # The coordinator schedules jobs and maintains the workforce size to match. As jobs
  # get added the coordinator creates workers to complete them. The number of
  # workers created will never exceed {QueueToTheFuture::maximum_workers}.
  class Coordinator
    include Singleton
    include Mutex_m
    
    # Creates the coordinator.
    # 
    # Note: This is a singleton class. To access the instance use 
    # {http://ruby-doc.org/stdlib/libdoc/singleton/rdoc/index.html Coordinator::instance}.
    def initialize
      @job_queue  = []
      @workforce  = []
      
      super
    end
    
    # The next scheduled job.
    #
    # @return [QueueToTheFuture::Job] Next job
    def next_job
      mu_synchronize { @job_queue.shift }
    end
    
    # The number of jobs waiting to be completed.
    #
    # @return [Fixnum] Size of job queue
    def job_count
      mu_synchronize { @job_queue.size }
    end
    
    # The number of workers being utilized to complete jobs.
    #
    # @return [Fixnum] Number of workers
    def workforce_size
      mu_synchronize { @workforce.size }
    end
    
    # Removes a worker from the workforce.
    #
    # @param [QueueToTheFuture::Worker] worker
    def relieve(worker)
      mu_synchronize { @workforce -= [worker] }
    end
    
    # Append a job to the job queue.
    #
    # @param [QueueToTheFuture::Job] job
    def schedule(job)
      mu_synchronize do
        @job_queue.push(job)
        
        if @workforce.size < QueueToTheFuture.maximum_workers && @workforce.size < @job_queue.size
          @workforce.push Worker.new(@workforce.size)
        end
      end
      
      job
    end
  end
end