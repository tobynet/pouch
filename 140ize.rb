#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# refs. termtterで必ず140文字投稿する https://gist.github.com/453709
# refs. http://apps.jgate.de/platform/source?pad
module AlwaysNLength
  DEFAULT_MAX_LENGTH = 140

  def self.convert(body, max_length = DEFAULT_MAX_LENGTH)
      body = body.chomp
      length = body.length
      mod = max_length % length
      ext = (0...length).to_a.sort_by{ rand }.take(mod)
      return body.each_char.with_index.map{|c, i| c * (max_length / length + (ext.include?(i) ? 1 : 0)) }.join('')
  end
end

case $PROGRAM_NAME
when __FILE__
  # ここにスクリプトをふつーに実行した場合をかきます
  program = File.basename($PROGRAM_NAME)
  USAGE = <<-EOD
usage: #{program} text [length]

example:
    $ #{program} "みんなでワイワイ バーベキューなう"
    みみみみみみみみみんんんんんんんんななななななななでででででででででワワワワワワワワイイイイイイイイイワワワワワワワワイイイイイイイイ        バババババババババーーーーーーーーベベベベベベベベキキキキキキキキュュュュュュュューーーーーーーーななななななななうううううううう
  or
    $ echo "みんなでワイワイ バーベキューなう" | #{program}
    みみみみみみみみみんんんんんんんんんなななななななななででででででででワワワワワワワワイイイイイイイイイワワワワワワワワイイイイイイイイババババババババーーーーーーーーベベベベベベベベキキキキキキキキュュュュュュュューーーーーーーーななななななななうううううううう
  EOD

  require 'net/http'
  if $stdin.tty? && ARGV.empty?
    puts USAGE
  else
    text = ARGV.shift || ARGF.read #|| "みんなでワイワイ バーベキューなう"
    length = (ARGV.shift || AlwaysNLength::DEFAULT_MAX_LENGTH).to_i
    puts AlwaysNLength.convert(text, length)
  end

when /rspec$/
  # ここにテストをかきます(rspec経由で実行されたときはテストとみなします)
  describe AlwaysNLength do
    context ".convert" do
      def shortly(text)
        text.gsub(/(.)\1*/){$1}
      end

      it "should be 140 length" do
        AlwaysNLength.convert("激ヤバ ").length.should == 140
      end

      it "works with short words" do
        shortly(AlwaysNLength.convert("やばい")).should == "やばい"
      end

      it "works with middle words" do
        shortly(AlwaysNLength.convert("みんなでワイワイ バーベキューなう")).should == "みんなでワイワイ バーベキューなう"
      end
    end
  end
end
