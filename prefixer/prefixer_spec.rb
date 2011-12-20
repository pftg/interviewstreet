#encoding: utf-8
$:.unshift File.dirname(__FILE__)

require 'rubygems'
require "bundler"
Bundler.setup(:default, :test)

require 'prefixer'

RSpec.configure do |config|
  config.mock_with :rr
end


