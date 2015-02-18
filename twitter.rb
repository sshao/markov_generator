#!/usr/bin/env ruby

require "optparse"
require "twitter"

options = {output: "corpuses/twitter.txt", count: 100, verbose: false}
username = nil

OptionParser.new do |opts|
  opts.banner = "Usage: twitter.rb username [options]"

  opts.on("-c", "--count NUM", "Specify number of tweets to fetch") do |c|
    options[:count] = c.to_i
  end

  opts.on("-o", "--output FILE", "Specify output file") do |o|
    options[:output] = o.to_s
  end

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
end.parse!

if ARGV.size != 1
  puts "Please input a username to fetch tweets for."
  exit
else
  username = ARGV.first
end

if options[:verbose]
  puts "Running with:"
  puts "\tusername: #{username}"
  options.each { |opt, val| puts "\t#{opt}: #{val}" }
end

client = Twitter::REST::Client.new do |config|
  config.consumer_key = ENV['TWITTER_API_KEY']
  config.consumer_secret = ENV['TWITTER_API_SECRET']
end

f = File.open(options[:output], "a")

tweets = client.user_timeline(username, exclude_replies: true)
count = tweets.size
last_id = tweets.last.id

tweets.each { |t| f.puts t.text }

while (count != 0) && (count <= options[:count])
  if options[:verbose]
    print "#{count}\r"
    $stdout.flush
  end

  tweets = client.user_timeline(username, exclude_replies: true, max_id: last_id)
  count += tweets.size
  last_id = tweets.last.id

  tweets.each { |t| f.puts t.text }
end

f.close
