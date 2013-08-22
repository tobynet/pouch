#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$VERBOSE = true
require 'minitest/autorun'
begin require 'minitest/pride' rescue LoadError end # Ignore error for old ruby

describe 'katakanaize.sh' do
  it 'works' do
    `./katakanaize.sh 'あなたとジャバ、今すぐダウンロード'`.must_equal 'アナタ ト ジャバ、 イマ スグ ダウンロード'
    `./katakanaize.sh '南無阿弥陀仏'`.must_equal 'ナムアミダブツ'
    `./katakanaize.sh '蒲生氏政'`.must_equal 'ガモウ ウジマサ'
  end
end
