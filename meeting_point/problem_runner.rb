$:.unshift File.dirname(__FILE__)
require 'benchmark'

module Kernel
  def puts *args
  end
end

Benchmark.bm do |x|
  x.report("10000") {
    ARGV << '10000.case'
    require 'meeting_point'
  }
end
