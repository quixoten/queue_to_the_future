require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module QueueToTheFuture
  describe "Coordinator" do
    before(:each) do
      QueueToTheFuture.maximum_workers = 15
      Coordinator.shutdown
    end
    
    it "should return the length of the job queue" do
      QueueToTheFuture.maximum_workers = 1
      Job.new() { sleep(0.1) }
      
      5.times do |i|
        Coordinator.queue_length.should == i
        Job.new() { sleep(0.1) }
        Coordinator.queue_length.should == i + 1
      end
    end
    
    it "should create up to the maximum allowed workers" do
      (QueueToTheFuture.maximum_workers + 10).times do
        Job.new { sleep(0.1) }
      end
      
      Coordinator.queue_length.should > 0
      Coordinator.workforce_size.should == QueueToTheFuture.maximum_workers
    end
    
    it "should shutdown gracefully" do
      5.times { Job.new { sleep(1) } }
      
      Coordinator.workforce_size.should == 5
      Coordinator.shutdown
      Coordinator.workforce_size.should == 0
    end
    
    it "should allow shutdown to be forced" do
      5.times { Job.new { Thread.stop } }
      Coordinator.shutdown(true)
    end
  end
end
