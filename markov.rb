class MarkovWord
  attr_accessor :string

  def initialize(string, start = false)
    @string = string
    @start = start
  end

  def start?
    @start
  end

  def punctuation?
    ( @string =~ /[!?\n]/ || @string == '.' )
  end

  def to_s
    @string
  end

  def eql?(other)
    @string == other.string
  end

  def hash
    @string.hash
  end
end

class MarkovChain
  def initialize(*corpuses)
    @corpus = {}
    @split_words = /(\.[[:blank:]]+)|(\.$)|([?!])|[[[:blank:]]]+/
    @split_sentence1 = /(?<=\n)\s*/
    @split_sentence2 = /(?<=[.!?])\s+/

    Array.new(corpuses).each do |c|
      text = File.exist?(c) ? File.read(c) : c
      parse_corpus(text)
    end

    puts generate_sentence
  end

  def generate_sentence
    max_length = 30
    sentence = []
    sentence << @corpus.keys.select(&:start?).sample

    until (sentence.last.punctuation?) || sentence.size > max_length
      word = weighted_random(@corpus[sentence.last])
      sentence << word
    end

    sentence.map(&:to_s).join(" ")
  end

  private
  def weighted_random(hash)
    cdf = {}
    acc = 0
    hash.each { |k, v| cdf[k] = (acc += v) }

    r = rand(0..acc)
    selected = cdf.find { |k, v| v >= r }

    selected[0]
  end

  def parse_corpus(text)
    sentences = text.split(@split_sentence1).map { |x| x.split(@split_sentence2) }.flatten

    sentences.each do |sentence|
      start = true
      sentence.split(@split_words).each_cons(2) do |w1, w2|
        word1 = MarkovWord.new(w1, start)
        start = false
        word2 = MarkovWord.new(w2)

        if @corpus.key? word1
          if @corpus[word1].key? word2
            @corpus[word1][word2] += 1
          else
            @corpus[word1][word2] = 1
          end
        else
          @corpus[word1] = {}
          @corpus[word1][word2] = 1
        end
      end
    end
  end
end
