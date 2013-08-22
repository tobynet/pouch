#!/usr/bin/env bash
#set -o xtrace       # for debug output.  ( abbr. set -x )
set -o errexit      # for exit on error. ( abbr. set -e )

function usage() {
  cat <<EOD
Usage: $(basename $0) [options] foo
    -h, --help          show help
Examples:
  $ $(basename $0) あなたとジャバ、今すぐダウンロード
  アナタ ト ジャバ、 イマ スグ ダウンロード

  $ $(basename $0) 南無阿弥陀仏
  ナムアミダブツ

  $ $(basename $0) 蒲生氏政
  ガモウ ウジマサ
EOD
}

# if no argument, then print usage
if [[ $# == 0 ]]; then
  usage
  exit 1
fi

# parse options
test_mode=false
while [ $# -gt 0 ]; do
  case "$1" in
    -h | --help | -help )
      usage
      exit ;;
    * )
      break ;;
  esac
done

# ----- write main logic here -----
if ! command -v mecab > /dev/null; then
  echo 'Error: Not found "mecab" which are needed to run this script!' >&2
  echo 'Hint: Please run "sudo apt-get install mecab" if you use Debian based linux now.' >&2
  exit 1
fi

( mecab --node-format="%pS%f[7]\s" --unk-format="%M" --eos-format="" <<<"$@" ) | sed 's/\s\+$//'

