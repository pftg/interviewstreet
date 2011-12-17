require 'rubygems'
require 'bundler/setup'

Bundler.require :default, :development

require File.dirname(__FILE__) + '/face_match.rb'

run Sinatra::Application
