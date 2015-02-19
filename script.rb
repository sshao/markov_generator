require "marky_markov"
require "optparse"
require "ostruct"

class OptsParser
  def self.parse(args)
    options = OpenStruct.new
    options.corpus = []
    options.delete = false
    options.verbose = false

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: ruby markov.rb [options]"

      opts.on("-a", "--add CORPUS", "Add corpus") do |corpus|
        options.corpus << corpus
      end

      opts.on("-d", "--delete", "Delete existing dictionary") do
        options.delete = true
      end

      opts.on("-v", "--verbose", "Run verbosely") do
        options.verbose = true
      end
    end

    opt_parser.parse!(args)
    options
  end
end

options = OptsParser.parse(ARGV)

dict_name = "dictionary"

if options.delete
  puts "Deleting dictionary '#{dict_name}'" if options.verbose
  MarkyMarkov::Dictionary.delete_dictionary! dict_name
end

markov = MarkyMarkov::Dictionary.new dict_name
markov.instance_variable_set(:@split_sentence, /(?<=[.!?:;\n])\s+/)

if !options.corpus.empty?
  options.corpus.each do |corpus|
    puts "Parsing corpus '#{corpus}'" if options.verbose
    markov.parse_file corpus
  end

  puts "Saving dictionaryy '#{dict_name}'" if options.verbose
  markov.save_dictionary!
end

puts "Generated sentence:\n#{'-'*40}" if options.verbose
puts markov.generate_n_sentences 1
