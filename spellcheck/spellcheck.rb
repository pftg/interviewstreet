require 'rubygems'
require 'text'

class String
  @@white_similarity = Text::WhiteSimilarity.new

  def each_qgram q = 2, &block
    (self.length - (q - 1)).times {|i| yield self[i .. i + q - 1].downcase }
  end

  def to_qgram q = 2
    (self.length - (q - 1)).times.map { |i|  self[i .. i + q - 1].downcase }
  end

  def levenshtein to
    Text::Levenshtein.distance to,self
  end
end

class SpellChecker
  THRESHOLD = 0.5

  attr_reader :index, :dictionary

  def initialize vocalabruary_path = '/usr/share/dict/words'
    index_dictionary vocalabruary_path
  end

  def index_dictionary path
    @index = {}
    @dictionary = File.new(path).readlines
    dictionary.each_with_index do |word, i|
      word.strip!
      word.to_qgram.uniq.each do |gram|
        indexes = @index[gram] ||= []
        indexes << i
      end
    end
  end

  def suggest word
    word = word.downcase

    word_qgrams = word.to_qgram

    # Add some improvements
    #word_qgrams += word_qgrams.map {|gram| gram.reverse }
    #word_qgrams += word_qgrams.map {|gram| gram.gsub(/[aeiyck]/,'e' => 'a', 'a' => 'e', 'i' => 'y', 'y' => 'i', 'c' => 'k', 'k' => 'c') }
    #word_qgrams.uniq!
    indexes = word_qgrams.map {|gram| index[gram] }

    candidate_words_with_freq = indexes.flatten.compact.inject(Hash.new(0)){|h,v| h[v] += 1;h }

    word_id_candidates = candidate_words_with_freq.keys

    word_id_candidates = word_id_candidates.sort_by {|a| -1 * candidate_words_with_freq[a] }#.find_all{|a| candidate_words_with_freq[a] > 1 }

    word_id_candidates.empty? and return nil

    word_candidates = word_id_candidates.map {|word_id| dictionary[word_id] }

    return word if word_candidates.include? word

    #distances = word_candidates.inject(Hash.new([])) {|h, candidate_word|
    #  h[word.levenshtein candidate_word] += [candidate_word]
    #  h
    #}

    #distances[distances.keys.min].sort_by {|w| (w.length - word.length).abs }

    suggestion = word_candidates.min_by {|candidate_word|
      word.levenshtein candidate_word
    }

    suggestion_distance = word.levenshtein suggestion
    (suggestion_distance) / word.length > THRESHOLD ?  nil : suggestion
  end
end

if __FILE__ == $0
  puts "SpellChecker 0.0.1!"
  puts "Indexing dictionary ..."
  spellchecker = SpellChecker.new #File.join(File.dirname(__FILE__), 'words')
  puts "Done."

  begin
    print "> "
    puts spellchecker.suggest (gets || "").strip
  end while true
end
