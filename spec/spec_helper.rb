$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'queue_to_the_future'
require 'spec'
require 'spec/autorun'
require 'benchmark'

Spec::Runner.configure do |config|
  
end
