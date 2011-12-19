VOWELS = %w(a e i o u y)

vocalabruary_path = '/usr/share/dict/words'
words = File.new(vocalabruary_path).readlines

string_randomizers = []

string_randomizers << random_word = proc {
 words[rand(words.length)].strip
}

# Case upper/lower
string_randomizers << lambda {|word|
  result = word.dup

  from = rand(result.length - 1)
  to = rand(result.length - from)
  result[from..to] = result[from..to].upcase

  result
}

string_randomizers << lambda{|word|
  result = word.dup

  i = rand(result.length)
  result.insert(i, result[i] * rand(result.length - 1))

  result
}


string_randomizers << lambda {|word|
  result = word.dup

  if i = result.index(/[#{VOWELS.join('')}]/, rand(result.length - 1))
    rand_vowel = VOWELS[rand(VOWELS.length)]
    result[i] = rand_vowel
  end

  result
}


word = random_word.call


(ARGV[0] || 10).to_i.times do
  word = string_randomizers[rand(string_randomizers.length)].call(word)
  puts word
end

puts "[exit]"

