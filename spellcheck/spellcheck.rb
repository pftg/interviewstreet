require 'rubygems'
require 'text'

class String
  def to_qgram q = 2
    (self.length - (q - 1)).times.map{ |i|  self[i .. i + q - 1] }.uniq
  end

  def levenshtein to
    Text::Levenshtein.distance to,self
  end
end

class SpellChecker
  THRESHOLD = 0.1

  attr_reader :index, :dictionary, :lengths

  def initialize vocalabruary_path = '/usr/share/dict/words'
    index_dictionary vocalabruary_path
  end

  def index_dictionary path
    @index = {}
    @lengths = []
    @dictionary = File.new(path).readlines
    dictionary.each_with_index do |word, i|
      word = dictionary[i] = word.strip.downcase

      lengths[i] = word.length

      word.to_qgram.each do |gram|
        indexes = @index[gram] ||=[]
        indexes << i
      end
    end
  end

  def suggest word
    word = word.downcase

    word_qgrams = word.to_qgram
    word_pairs_size = word_qgrams.size

    indexes = word_qgrams.map {|gram| index[gram] }

    candidate_words_with_freq = indexes.flatten.compact.inject(Hash.new(0)){|h,v| h[v] += 1;h }

    best_match = candidate_words_with_freq.map {|w,f| [w, 2.0 * f  / (word_pairs_size + lengths[w] + 1.0).to_f] }.sort_by{|a| -1 * a.last}.first

    best_match.last > THRESHOLD ? dictionary[best_match.first] : nil
  end
end

if __FILE__ == $0
  puts "SpellChecker 0.0.1!"
  puts "Indexing dictionary ..."
  spellchecker = SpellChecker.new #File.join(File.dirname(__FILE__), 'words')
  puts "Done."

  require 'readline'

  # Store the state of the terminal
  stty_save = `stty -g`.chomp
  trap('INT') { system('stty', stty_save); exit }

  Readline.completion_append_character = " "
  Readline.completion_proc = proc { |s| spellchecker.dictionary.grep( /^#{Regexp.escape(s)}/ ) }


  while user_input = Readline.readline('> ', true)
    puts spellchecker.suggest(user_input) || "NO SUGGESTION"
  end
end
