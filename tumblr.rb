#!/usr/bin/env ruby

require "optparse"
require "tumblr_client"

def parse_response(p, tag)
  body = nil
  if p["type"] == "text"
    body = p["body"]
  else
    body = p["caption"]
  end

  body = p["tags"].reject{ |x| x == tag}.join(" ") if body.nil?

  body
end

options = {output: "corpuses/tumblr.txt", count: 100, verbose: false}
tag = nil

OptionParser.new do |opts|
  opts.banner = "Usage: tumblr.rb tag [options]"

  opts.on("-c", "--count NUM", "Specify number of posts to fetch") do |c|
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
  puts "Please input a tag to fetch posts for."
  exit
else
  tag = ARGV.first
end

if options[:verbose]
  puts "Running with:"
  puts "\ttag: #{tag}"
  options.each { |opt, val| puts "\t#{opt}: #{val}" }
end

Tumblr.configure do |config|
  config.consumer_key = ENV['OAUTH_CONSUMER']
end

client = Tumblr::Client.new

f = File.open(options[:output], "a")

posts = client.tagged(tag, filter: "text")
count = posts.size
returned = posts.size
last_ts = posts.last["timestamp"]

posts.each { |p| f.puts parse_response(p, tag) }

while (returned > 0) && (count < options[:count])
  if options[:verbose]
    print "#{returned} | #{count}\r"
    $stdout.flush
  end

  posts = client.tagged(tag, filter: "text", before: last_ts)
  returned = posts.size
  count += returned
  last_ts = posts.last["timestamp"]

  posts.each { |p| f.puts parse_response(p, tag) }
end

f.close
