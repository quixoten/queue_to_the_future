require 'thread'
require 'mutex_m'
require 'singleton'

require 'queue_to_the_future/coordinator'
require 'queue_to_the_future/job'

module QueueToTheFuture
  # Returns the current version of QueueToTheFuture
  def self.VERSION
    @@version ||= open(File.join(File.dirname(__FILE__), '..', 'VERSION')).read.strip
  end
  
  # The maximum number of workers to create for processing jobs.
  #
  # @return [Fixnum] Default is 15
  def self.maximum_workers
    @@maximum_workers ||= 15
  end
  
  # Setter method for {maximum_workers}
  #
  # @param [Fixnum] number Any integer greater than 0
  # @return [Fixnum] number given
  # @raise [StandardError] If the number given is less than 1
  def self.maximum_workers=(number)
    raise StandardError.new("Bad workforce size: #{number}. Must be at least 1.") unless (number = number.to_i) >= 1
    @@maximum_workers = number
  end
end

module Kernel
  # Main interface for asynchronous job scheduling. (Where the magick begins)
  # 
  # @example
  #   http        = Net::HTTP.new("ia.media-imdb.com")
  #   image_path  = "/images/M/MV5BMTkzNDQyMjc0OV5BMl5BanBnXkFtZTcwNDQ4MDYyMQ@@._V1._SX100_SY133_.jpg"
  #   
  #   image = Future(image_path) do |path|
  #     http.request(Net::HTTP::Get.new(path)).body
  #   end
  # 
  #   # do other things
  #
  #   puts image.size # => 6636
  #
  # @param (see QueueToTheFuture::Job#initialize)
  # @return [QueueToTheFuture::Job] Your proxy into the future
  def Future(*args, &block)
    QueueToTheFuture::Job.new(*args, &block)
  end
end