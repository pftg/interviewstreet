require 'rubygems'
require 'text'

class String
  def levenshtein to
    Text::Levenshtein.distance to,self
  end

  def to_consonants
    self.gsub(/[aeiouy]/,'*').gsub(/(\w|\*)\1+/, '\1')
  end
end

class SimpleSpellChecker
  attr_reader :index

  def initialize vocalabruary_path = '/usr/share/dict/words'
    index_dictionary vocalabruary_path
  end

  def index_dictionary path
    @index = Hash.new([])
    dictionary = File.new(path).readlines
    dictionary.each_with_index do |word, i|
      normalized_word = word.strip.downcase
      hash = normalized_word.to_consonants
      @index[hash] += [normalized_word]
    end
  end

  def suggest word
    word = word.downcase
    word_candidates = index[word.to_consonants]

    word_candidates.min_by {|candidate_word|
      word.levenshtein candidate_word
    }
  end
end

if __FILE__ == $0
  puts "SimpleSpellChecker 0.0.1!"
  puts "Indexing dictionary ..."
  spellchecker = SimpleSpellChecker.new #File.join(File.dirname(__FILE__), 'words')
  puts "Done."

  begin
    print "> "
    user_input = (gets || "").strip
    break if user_input == "[exit]"
    suggestion = spellchecker.suggest user_input
    puts suggestion || "NO SUGGESTION"
  end while true
end
