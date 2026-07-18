#!/usr/bin/env bash

set -euo pipefail

cache="${BASH_SOURCE[0]%/*}/rainbow-logo.cache"
speed=20

usage() {
  printf 'Usage: %s [--speed MILLISECONDS] [--play CACHE]\n' "${0##*/}"
}

while (($#)); do
  case $1 in
    -s | --speed)
      speed=${2:?--speed requires milliseconds}
      shift 2
      ;;
    -P | --play)
      cache=${2:?--play requires a cache path}
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
done

[[ $speed =~ ^[1-9][0-9]*$ ]] || { printf 'speed must be a positive integer\n' >&2; exit 2; }
[[ -r $cache ]] || { printf 'cannot read cache: %s\n' "$cache" >&2; exit 1; }

mapfile -d '' -t frames <"$cache"
((${#frames[@]})) || { printf 'cache contains no frames: %s\n' "$cache" >&2; exit 1; }

cleanup() {
  printf '\e[0m\e[?25h'
}
trap cleanup EXIT
trap 'exit 0' INT TERM

printf '\e[?25l\e[H'
for ((frame = 0;; frame = (frame + 1) % ${#frames[@]})); do
  printf '\e[H%s' "${frames[frame]}"
  sleep "${speed}e-3"
done
