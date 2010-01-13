require 'singleton'

module QueueToTheFuture  
  class Coordinator
    include Singleton
    
    def initialize
      @job_queue  = []
      @workforce  = []
      @lock       = Mutex.new
    end
    
    def next_job
      synchronize { @job_queue.shift }
    end
    
    def job_count
      synchronize { @job_queue.size }
    end
    
    def workforce_size
      synchronize { @workforce.size }
    end
    
    def relieve(worker)
      synchronize { @workforce -= [worker] }
    end
    
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