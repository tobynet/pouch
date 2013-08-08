#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# refs. termtterで必ず140文字投稿する https://gist.github.com/453709
# refs. http://apps.jgate.de/platform/source?pad
module AlwaysNLength
  DEFAULT_MAX_LENGTH = 140

  class << self
    def convert(body, max_length = DEFAULT_MAX_LENGTH)
        body = body.chomp
        length = body.length
        mod = max_length % length
        ext = (0...length).to_a.sort_by{ rand }.take(mod)
        return body.each_char.with_index.map{|c, i| c * (max_length / length + (ext.include?(i) ? 1 : 0)) }.join('')
    end

    def run_test
      require 'minitest/autorun'
      begin
        require 'minitest/pride'
      rescue LoadError
      end

      describe AlwaysNLength do
        describe ".convert" do
          def shortly(text)
            text.gsub(/(.)\1*/){$1}
          end

          it "should be 140 length" do
            AlwaysNLength.convert("激ヤバ ").length.must_equal 140
          end

          it "works with short words" do
            shortly(AlwaysNLength.convert("やばい")).must_equal "やばい"
          end

          it "works with middle words" do
            shortly(AlwaysNLength.convert("みんなでワイワイ バーベキューなう")).must_equal "みんなでワイワイ バーベキューなう"
          end
        end

        it 'is modular' do
          system(%{ruby -e 'require "./140ize"; AlwaysNLength'}).must_equal true
        end
      end
      
    end
  end
end

if $PROGRAM_NAME == __FILE__
  # Parse options
  require 'optparse'
  program = File.basename($PROGRAM_NAME)

  opt = OptionParser.new do |opts|
    opts.banner = '140ize: Text Length Maximizer'
    opts.separator <<-EOD

  吉吉吉吉吉吉吉吉吉吉吉吉吉吉吉吉
  𠮷 Iresponsible design siries 𠮷
  吉吉吉𠮷吉吉吉吉吉吉吉吉吉吉吉吉

Usage: #{program} text [length]

Examples:
    $ #{program} "みんなでワイワイ バーベキューなう"
    みみみみみみみみみんんんんんんんんななななななななでででででででででワワワワワワワワイイイイイイイイイワワワワワワワワイイイイイイイイ        バババババババババーーーーーーーーベベベベベベベベキキキキキキキキュュュュュュュューーーーーーーーななななななななうううううううう
  or
    $ echo "みんなでワイワイ バーベキューなう" | #{program}
    みみみみみみみみみんんんんんんんんんなななななななななででででででででワワワワワワワワイイイイイイイイイワワワワワワワワイイイイイイイイババババババババーーーーーーーーベベベベベベベベキキキキキキキキュュュュュュュューーーーーーーーななななななななうううううううう

Options:
  EOD
    opts.on_tail('-t', '--test', 'Run test **FOR DEVELOPER** ') do
      AlwaysNLength.run_test
      exit
    end

    opts.on_tail('-h', '--help', 'Show this message') do
      puts opts
      exit 1
    end
  end
  opt.parse!

  if $stdin.tty? && ARGV.empty?
    puts opt
    exit 1
  else
    text = ARGV.shift || ARGF.read #|| "みんなでワイワイ バーベキューなう"
    length = (ARGV.shift || AlwaysNLength::DEFAULT_MAX_LENGTH).to_i
    puts AlwaysNLength.convert(text, length)
  end
end
