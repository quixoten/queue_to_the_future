require 'singleton'

module QueueToTheFuture
  # The coordinator schedules jobs and maintains the workforce size to match. As jobs
  # get added the coordinator creates workers to complete them. The number of
  # workers created will never exceed {QueueToTheFuture::maximum_workers}.
  class Coordinator
    include Singleton
    
    # Creates the coordinator.
    # 
    # Note: This is a singleton class. To access the instance use 
    # {http://ruby-doc.org/stdlib/libdoc/singleton/rdoc/index.html Coordinator::instance}.
    def initialize
      @job_queue  = []
      @workforce  = []
      @lock       = Mutex.new
    end
    
    # The next scheduled job.
    #
    # @return [QueueToTheFuture::Job] Next job
    def next_job
      synchronize { @job_queue.shift }
    end
    
    # The number of jobs waiting to be completed.
    #
    # @return [Fixnum] Size of job queue
    def job_count
      synchronize { @job_queue.size }
    end
    
    # The number of workers being utilized to complete jobs.
    #
    # @return [Fixnum] Number of workers
    def workforce_size
      synchronize { @workforce.size }
    end
    
    # Removes a worker from the workforce.
    #
    # @param [QueueToTheFuture::Worker] worker
    def relieve(worker)
      synchronize { @workforce -= [worker] }
    end
    
    # Append a job to the job queue.
    #
    # @param [QueueToTheFuture::Job] job
    def schedule(job)
      synchronize do
        @job_queue.push(job)
        
        if @workforce.size < QueueToTheFuture.maximum_workers && @workforce.size < @job_queue.size
          @workforce.push Worker.new(@workforce.size)
        end
      end
      
      job
    end
    
    private
    def synchronize(&block)
      @lock.synchronize(&block)
    end
  end
end