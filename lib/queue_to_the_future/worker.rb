module QueueToTheFuture
  class Worker
    def initialize(index)
      @index        = index
      @coordinator  = Coordinator.instance
      dispatch
    end
    
    def dispatch
      Thread.new(@index) do |index|
        while index < QueueToTheFuture.maximum_workers && (work = @coordinator.next_job)
          work.__execute__
          Thread.pass()
        end
        
        @coordinator.relieve(self)
      end
    end
  end
end