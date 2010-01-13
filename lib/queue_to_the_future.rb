require 'thread'

require 'queue_to_the_future/coordinator'
require 'queue_to_the_future/worker'
require 'queue_to_the_future/job'

module QueueToTheFuture
  @@maximum_workers = 15
  
  def self.maximum_workers
    @@maximum_workers
  end
  
  def self.maximum_workers=(number)
    raise StandardError.new("Bad workforce size: #{number}. Must be at least 1.") unless (number = number.to_i) >= 1
    @@maximum_workers = number
  end
  
  def self.schedule(job)
    Coordinator.instance.schedule(job)
  end
end

module Kernel
  def Future(*args, &block)
    QueueToTheFuture.schedule(QueueToTheFuture::Job.new(*args, &block))
  end
end