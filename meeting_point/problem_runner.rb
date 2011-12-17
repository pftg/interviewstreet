$:.unshift File.dirname(__FILE__)
require 'benchmark'

puts 'Start!'

tm = Benchmark.measure do
  require 'meeting_point'
end

puts "Time: #{tm}"
