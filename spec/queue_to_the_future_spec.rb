require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "QueueToTheFuture" do
  it "should allow the workforce size to be modified" do
    lambda { QueueToTheFuture.maximum_workers = 20 }.should_not raise_exception()
  end
  
  it "should not accept a workforce size less than 1" do
    lambda { QueueToTheFuture.maximum_workers = 0 }.should raise_exception(StandardError, /Bad workforce size/)
  end
  
  it "should provide the version being used" do
    QueueToTheFuture.VERSION.should match(/\d+\.\d+\.\d+/)
  end
  
  it "should provide a Kernel level API for job creation" do
    f = Future() { sleep(0.1); "blargh" }
    f.inspect.should match(/QueueToTheFuture::Job/)
  end
end
