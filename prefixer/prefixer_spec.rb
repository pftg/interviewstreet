#encoding: utf-8
$:.unshift File.dirname(__FILE__)

require 'rubygems'
require "bundler"
Bundler.setup(:default, :test)

require 'prefixer'

RSpec.configure do |config|
  config.mock_with :rr
end

describe "#shunting_yard" do
  context "simple sum" do
    it "first operand should be in first output cell" do
      result = shunting_yard "3 + 2"
      result.should == %w(3 2 +)
    end
  end

  context "expression with braces" do
    subject { shunting_yard "( 2 * ( 5 + 1 ) )"}

    it "should evaluate brace expression first" do
      mul_index = subject.index '*'
      add_index = subject.index '+'
      add_index.should < mul_index
    end

    it "should not add to output braces" do
      subject.should_not include("(")
    end
  end
end

describe "#eval_rpn_expression" do
  context "valid example" do
    subject { eval_rpn_expression %w[3 2 +]}
    it "should return '3 2 +'" do
      subject.should == "3 2 +"
    end
  end
end
