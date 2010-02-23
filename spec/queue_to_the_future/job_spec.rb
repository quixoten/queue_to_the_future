require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module QueueToTheFuture
  describe "Job" do
    it "should return immediately" do
      Benchmark.realtime() do
        j = Job.new { sleep(0.1); "value" }
      end.should be_close(0, 0.001)
    end
    
    it "should block until completed on access" do
      Benchmark.realtime() do
        j = Job.new { sleep(0.1); "blargh" }
        j.should == "blargh"
      end.should be_close(0.1, 0.001)
    end
    
    it "should pass all arguments to the block" do
      j = Job.new(1,2,3) { |*args| args.join(",") }
      j.should == "1,2,3"
    end
    
    it "should handle exceptions" do
      j = nil
      
      lambda { j = Job.new { raise StandardError.new("Mock Exception") } }.should_not raise_exception()
      lambda { j.to_s }.should raise_exception(StandardError, "Mock Exception")
    end
  end
end
