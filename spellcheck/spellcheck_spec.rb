#encoding: utf-8
$:.unshift File.dirname(__FILE__)

require 'rubygems'
require "bundler"
Bundler.setup(:default, :test)

require 'spellcheck'

RSpec.configure do |config|
  config.mock_with :rr
end

describe SpellChecker do
  describe "#initialize" do
    it "should index vocalabruary" do
      any_instance_of(SpellChecker) do |s|
        mock(s).index_dictionary('/usr/share/dict/words') { true }
      end

      SpellChecker.new
    end
  end

  describe "#index_dictionary" do
    subject { SpellChecker.new './words'}

    it "should build all 2-grams from all words" do
      subject.index.keys.sort == %w(pa au ul ni ik ki it to oc ch hk in ru ub by ra ai il ls de ev ve el lo op pe er ns si id)
    end

    it "should add line number of word for each 2-gram" do
      subject.index["de"].should == [4, 5]
    end
  end

  describe "#suggest" do
    let(:spellchecker) { SpellChecker.new './words' }

    context "non dictionary word" do
      it "should return nil" do
        suggestion = spellchecker.suggest 'QWEASD'
        suggestion.should be_nil
      end
    end

    context "blank word come" do
      it "should return nil" do
        spellchecker.suggest("").should be_nil
      end
    end

    context "word with repeated letters" do
      it "should return sheep for sheeeep" do
        suggestion = spellchecker.suggest 'sheeeep'
        suggestion.should == 'sheep'
      end
    end

    context "word with incorrect vowels" do
      it "should return ruby for raby" do
        suggestion = spellchecker.suggest 'raby'
        suggestion.should == 'ruby'
      end
    end

    it "should build word ids list from vocalabruary for word" do
      spellchecker.suggest 'inSIDE'
    end

    it "should fix case" do
      suggestion = spellchecker.suggest "inSIDE"
      suggestion.should == "inside"
    end
  end
end
