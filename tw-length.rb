#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# Implements
module TwLength
  # ref. https://dev.twitter.com/docs/api/1.1/get/help/configuration
  # Someone help me with getting twitter configuration without oAuth? ;(
  #
  #   RESERVED_LENGTH.must_eqal [short_url_length_http, short_url_length_https].max
  MAX_RESERVED_LENGTH = 23

  class << self
    def length(message)
      # ref. https://github.com/shokai/tw/blob/v0.4.6/lib/tw/client/helper.rb
      result = message.chars.size
      message.scan(/https?:\/\/[^\s]+/).each do |x|
        result += MAX_RESERVED_LENGTH - x.chars.size
      end
      result
    end

    def run(message)
      puts length(message)
    end

    def run_test
      require 'minitest/autorun'
      begin
        require 'minitest/pride'
      rescue LoadError
      end

      describe TwLength do
        it '.length without URI' do
          TwLength.length('foobar').must_equal 6
          TwLength.length('だるい').must_equal 3
        end

        it '.length with URI' do
          TwLength.length('foobar http://example.com/').must_equal 29 + 1
          TwLength.length('だるい https://example.com/').must_equal 27
          TwLength.length('𠮷野家 https://example.com/ http://example.com/').must_equal 50 + 1
        end

        it 'is modular' do
          system(%{ruby -e 'require "./tw-length"; TwLength'}).must_equal true
        end
      end
    end

  end
end

if $PROGRAM_NAME == __FILE__
  # Parse options
  require 'optparse'
  program_name = File.basename(__FILE__)
  opt = OptionParser.new do |opts|
    opts.banner = 'TwLength: Irresponsible message length calculator for posting twitter'
    opts.separator <<-EOD

  吉吉吉吉吉吉吉吉吉吉吉吉吉吉吉吉
  𠮷 Iresponsible design siries 𠮷
  吉吉吉𠮷吉吉吉吉吉吉吉吉吉吉吉吉

  Usage: #{program_name} [message]

  Examples:
    $ #{program_name} '𠮷野屋'
    3

    $ #{program_name} '𠮷野屋 http://example.com/ https://example.com/'
    51

    $ echo foobar | #{program_name}
    6

  Options:
    EOD

    opts.on('-s', '--sample', 'Run sample code as usage or examples') do |v|
      cmd = "ruby #{__FILE__} goto 𠮷野屋"
      puts "$ #{cmd}"
      system(*cmd.split)
      exit
    end

    opts.on_tail('-t', '--test', 'Run test **FOR DEVELOPER** ') do
      TwLength.run_test
      exit
    end

    opts.on_tail('-h', '--help', 'Show this message') do
      puts opts
      exit
    end
  end
  opt.parse!

  if $stdin.tty? && ARGV.empty?
    puts opt
    exit 1
  else
    text = ARGV.shift || ARGF.read.chomp #|| 'みんなでワイワイ バーベキューなう'
  end

  TwLength.run(text)
end
