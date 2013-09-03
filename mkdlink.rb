#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'open-uri'

begin
  require 'nokogiri'
rescue LoadError
end

# implements
module MarkdownLink
  class << self
    # from_uri('http://example.com/') => '[Example Domain](http://example.com/)'
    # from_uri('http://example.com/', type: :inline) => '[Example Domain](http://example.com/)'
    # from_uri('http://example.com/', type: :reference) => '[]: http://example.com/ "Example Domain"'
    def from_uri(url, opt = {})

      uri = URI(url)
      title = fetch_title(uri)
      
      case opt[:type]
      when :reference
        "[]: #{uri.to_s} \"#{escaped_title(title)}\""
      else
        "[#{escaped_title(title)}](#{uri.to_s})"
      end
    end

    # escaped_title("[foo] - title(test)") => '\[foo\] - title\(test\)'
    def escaped_title(title)
      title.gsub(/([\[\]\(\)])/){ '\\' + $1 }
    end

    # fetch_title(URI('http://example.com/')) => 'Example Domain'
    def fetch_title(uri)
      if Module.const_defined?(:Nokogiri)
        fetch_title_by_using_nokogiri(uri)
      else
        fetch_title_by_using_stdlib(uri)
      end
    end

    # fetch_title_by_using_nokogiri(URI('http://example.com/')) => 'Example Domain'
    def fetch_title_by_using_nokogiri(uri)
      Nokogiri::HTML(uri.read).title
    end

    # fetch_title_by_using_stdlib(URI('http://example.com/')) => 'Example Domain'
    def fetch_title_by_using_stdlib(uri)
      match = uri.read.scan(/<title>(.*?)<\/title>/i)
      return "" unless match.first && match.first.first

      match.first.first
    end

    # Spec
    def run_test
      require 'minitest/autorun'
      require 'minitest/mock'
      begin
        require 'minitest/pride'
      rescue LoadError
      end

      describe MarkdownLink do
        it 'works by using .from_uri' do
          MarkdownLink.stub(:fetch_title, 'pi(yo]') do
            MarkdownLink.from_uri('http://example.com/').must_equal '[pi\(yo\]](http://example.com/)'
          end

          MarkdownLink.stub(:fetch_title, 'piyo') do
            MarkdownLink.from_uri('http://example.com/', type: :reference).must_equal '[]: http://example.com/ "piyo"'
          end
        end

        it 'works by using .escaped_title' do
          MarkdownLink.escaped_title('[foo] - title(test)').must_equal '\[foo\] - title\(test\)'
        end
        
        it 'works by using .fetch_title' do
          # TOOD: use Mock
          begin
            # Save environment
            old_nokogiri = Object.const_get(:Nokogiri) if Object.const_defined?(:Nokogiri)
            old_verbose = $VERBOSE
            $VERBOSE = nil

            # When Nokogiri is loaded
            Object.const_set(:Nokogiri, true)
            MarkdownLink.stub(:fetch_title_by_using_nokogiri, 'fizzbuzz') do
               MarkdownLink.fetch_title(URI('http://example.com/')).must_equal 'fizzbuzz'
            end

            # When Nokogiri is not loaded
            Object.send(:remove_const, :Nokogiri)
            MarkdownLink.stub(:fetch_title_by_using_stdlib, 'fizzbuzz') do
               MarkdownLink.fetch_title(URI('http://example.com/')).must_equal 'fizzbuzz'
            end
          ensure
            # Restore environment
            Object.const_set(:Nokogiri, old_nokogiri) if old_nokogiri
            $VERBOSE = old_verbose
          end
        end

        it 'works by using .fetch_title_by_using_nokogiri' do
          uri = URI('http://example.com/')
          uri.stub(:read, '<title>foobar</title>') do
            MarkdownLink.fetch_title_by_using_nokogiri(uri).must_equal 'foobar'
          end
        end

        it 'works by using .fetch_title_by_using_stdlib' do
          uri = URI('http://example.com/')
          uri.stub(:read, '<title>foobar</title>') do
            MarkdownLink.fetch_title_by_using_stdlib(uri).must_equal 'foobar'
          end
        end

        it 'is modular' do
          system(%{ruby -e 'require "./mkdlink"; MarkdownLink'}).must_equal true
        end
      end
    end
  end
end


if $PROGRAM_NAME == __FILE__
  # Parse options
  require 'optparse'
  program = File.basename($PROGRAM_NAME)

  in_test_mode = false
  link_type = nil

  opt = OptionParser.new do |opts|
    opts.banner = 'MarkdownLink: Link Text Generator for Markdown from URI'
    opts.separator <<-EOD

  吉吉吉吉吉吉吉吉吉吉吉吉吉吉吉吉
  𠮷 Irresponsible design series 𠮷
  吉吉吉𠮷吉吉吉吉吉吉吉吉吉吉吉吉

Usage: #{program} <url>

Examples:
    $ #{program} 'http://example.com/'
    [Example Domain](http://example.com/)

    $ #{program} -r 'http://example.com/'
    []: http://example.com/ "Example Domain"

Options:
  EOD
    opts.on('-i', '--inline', 'Output link as *inline*') do
      link_type = :inline
    end

    opts.on('-r', '--reference', 'Output link as *reference*') do
      link_type = :reference
    end

    opts.on_tail('-t', '--test', 'Run test **FOR DEVELOPER** ') do
      in_test_mode = true
    end

    opts.on_tail('-h', '--help', 'Show this message') do
      puts opts
      exit 1
    end
  end
  opt.parse!

  if in_test_mode
    MarkdownLink.run_test
  elsif $stdin.tty? && ARGV.empty?
    puts opt
    exit 1
  else
    text = ARGV.shift || ARGF.read
    puts MarkdownLink.from_uri(text, type: link_type)
  end
end
