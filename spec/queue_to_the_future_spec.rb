require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "QueueToTheFuture" do
  it "should work" do
    start = Time.now.to_f
    
    f = Future(1, 2, 3) do |*args|
      sleep(0.1); args
    end
    
    QueueToTheFuture::Coordinator.instance.workforce_size.should be(1)
    f.inspect.should match(/^#<QueueToTheFuture::Job/)
    f.should eql([1,2,3])
    (Time.now.to_f - start).should be_close(0.1, 0.001)
    Thread.pass
    QueueToTheFuture::Coordinator.instance.workforce_size.should be(0)
  end
end
