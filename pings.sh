#!/usr/bin/env bash
#set -o xtrace       # for debug output.  ( abbr. set -x )
set -o errexit      # for exit on error. ( abbr. set -e )

# ref. 【小ネタ】複数のホストにpingを打ってその結果をわかりやすく出力する http://nullpopopo.blogcube.info/2008/05/ping.html


function usage() {
  cat <<EOD
Multiping utility
Usage: $(basename $0) [options] \$ips
    -h, --help          show help

Examples: $(basename $0) 192.168.1.{1..10}
EOD
}

# if no argument, then print usage
if [[ $# == 0 ]]; then
  usage
  exit 1
fi

# parse options
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
if [[ -t 1 ]]; then
  # stdout is a terminal
  alive_color='\e[0;32m'
  dead_color='\e[7;31m'
  strong_color='\e[1m'
  end_color='\e[0m'
else
  # stdout is not a terminal
  alive_color=
  dead_color=
  strong_color=
  end_color=
fi

for i in $@; do 
  ping  -c 1 -s 1 -w 1 "$i" | \
    if grep "bytes from" --silent; then \
      echo -e "${alive_color}"`date`"\t${i}\t${strong_color}alive${end_color}"; \
    else \
      echo -e "${dead_color}"`date`"\t${i}\t${strong_color}DEAD${end_color}" ; \
    fi
done
