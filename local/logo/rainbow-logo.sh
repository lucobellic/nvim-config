#!/usr/bin/env bash

set -euo pipefail

readonly VERSION="1.0.0"
readonly SCRIPT_NAME=$(basename "$0")

default_logo=(
  "                                                                     "
  "                                                                   "
  "       ████ ██████           █████      ██                   "
  "      ███████████             █████                           "
  "      █████████ ███████████████████ ███   ███████████ "
  "     █████████  ███     ████████████ █████ ██████████████ "
  "    █████████ ██████████ █████████ █████ █████ ████ █████ "
  "  ███████████ ███    ███ █████████ █████ █████ ████ █████ "
  " ██████  █████████████████████ ████ ████ █████ ████ █████ "
  " █████    █ █████████ ███████   ██  ██  ████ ████ ████ "
  "                                                                     "
  "                       The Ultimate Text Editor                      "
  "                           Rainbow Edition                           "
)

animation_speed=30
phase_offset=6
char_offset=3
logo_file=""
logo=()
generate_file=""
play_file=""
total_frames=360

cleanup() {
  tput sgr0
  tput cnorm
  tput cup "$(tput lines)" 0
  exit 0
}

trap cleanup SIGINT SIGTERM

hsl_to_rgb() {
  local h=$1
  local s=${2:-1.0}
  local l=${3:-0.5}

  local c
  local x
  local m
  local r=0
  local g=0
  local b=0

  c=$(((1000 * 2 * l - 1000) * s))
  if ((c < 0)); then c=$((-c)); fi
  c=$((c / 1000))

  local h_prime=$(((h % 360) / 60))
  x=$((c * (1000 - (h_prime % 2 * 1000 - 1000))))
  if ((x < 0)); then x=$((-x)); fi
  x=$((x / 1000))

  case $h_prime in
  0)
    r=$c
    g=$x
    b=0
    ;;
  1)
    r=$x
    g=$c
    b=0
    ;;
  2)
    r=0
    g=$c
    b=$x
    ;;
  3)
    r=0
    g=$x
    b=$c
    ;;
  4)
    r=$x
    g=0
    b=$c
    ;;
  5)
    r=$c
    g=0
    b=$x
    ;;
  esac

  m=$((l * 1000 - c * 500))
  if ((m < 0)); then m=$((1000 + m)); fi

  rgb_r=$(((r * 255 + m) / 1000))
  rgb_g=$(((g * 255 + m) / 1000))
  rgb_b=$(((b * 255 + m) / 1000))
}

simple_hsl_to_rgb() {
  local h=$1

  h=$((h % 360))

  local segment=$((h / 60))
  local offset=$((h % 60))

  local r=255 g=255 b=255

  case $segment in
  0)
    r=255
    g=$((offset * 255 / 60))
    b=0
    ;;
  1)
    r=$(((60 - offset) * 255 / 60))
    g=255
    b=0
    ;;
  2)
    r=0
    g=255
    b=$((offset * 255 / 60))
    ;;
  3)
    r=0
    g=$(((60 - offset) * 255 / 60))
    b=255
    ;;
  4)
    r=$((offset * 255 / 60))
    g=0
    b=255
    ;;
  5)
    r=255
    g=0
    b=$(((60 - offset) * 255 / 60))
    ;;
  esac

  rgb_r=$r
  rgb_g=$g
  rgb_b=$b
}

load_logo() {
  logo=()

  if [[ -n "$logo_file" ]]; then
    if [[ ! -f "$logo_file" ]]; then
      echo "Error: File '$logo_file' not found" >&2
      exit 1
    fi
    if [[ ! -r "$logo_file" ]]; then
      echo "Error: Cannot read file '$logo_file'" >&2
      exit 1
    fi
    while IFS= read -r line || [[ -n "$line" ]]; do
      logo+=("$line")
    done <"$logo_file"
  elif [[ ! -t 0 ]]; then
    while IFS= read -t 0.1 -r line || [[ -n "$line" ]]; do
      logo+=("$line")
    done
    if [[ ${#logo[@]} -eq 0 ]]; then
      logo=("${default_logo[@]}")
    fi
  else
    logo=("${default_logo[@]}")
  fi

  if [[ ${#logo[@]} -eq 0 ]]; then
    echo "Error: No logo data provided" >&2
    exit 1
  fi
}

print_usage() {
  cat <<EOF
$SCRIPT_NAME v$VERSION - Animated Rainbow ASCII Logo

Usage: $SCRIPT_NAME [OPTIONS] [FILE]

Apply an animated rainbow wave effect to ASCII art.

Options:
    -s, --speed NUM    Animation speed in milliseconds (default: 30)
                       Lower values = faster animation
    -p, --phase NUM    Phase offset between lines (default: 6)
                       Controls diagonal wave angle (lower = larger waves)
    -c, --char NUM     Character color offset (default: 1)
                       Controls color variation per character (lower = smoother)
    -g, --generate F   Generate complete rainbow cycle to file
                       Saves 360 pre-rendered frames for fast playback
    -P, --play F       Play animation from pre-generated frame cache
                       Uses simple counter increment, no color calculations
    -h, --help         Show this help message
    -v, --version      Show version information

Arguments:
    FILE               Optional file containing ASCII art
                       If not provided, reads from stdin
                       If no stdin, uses built-in demo logo

Examples:
    $SCRIPT_NAME                    # Use built-in demo logo
    $SCRIPT_NAME logo.txt           # Animate logo from file
    $SCRIPT_NAME -s 50 logo.txt     # Slow animation (50ms)
    $SCRIPT_NAME -s 10 logo.txt     # Fast animation (10ms)
    cat logo.txt | $SCRIPT_NAME     # Read from stdin

    # Pre-render and play (faster, lower CPU):
    $SCRIPT_NAME -g frames.cache logo.txt   # Generate frame cache
    $SCRIPT_NAME -P frames.cache            # Play from cache

Terminal Requirements:
    - 24-bit true color support
    - Compatible with: iTerm2, GNOME Terminal, Kitty,
      Alacritty, Windows Terminal, and most modern terminals

Press Ctrl+C to stop the animation.

EOF
}

print_version() {
  echo "$SCRIPT_NAME v$VERSION"
}

parse_arguments() {
  while [[ $# -gt 0 ]]; do
    case $1 in
    -s | --speed)
      if [[ -z "${2:-}" ]] || [[ "$2" =~ ^- ]]; then
        echo "Error: --speed requires a numeric argument" >&2
        exit 1
      fi
      animation_speed="$2"
      shift 2
      ;;
    -p | --phase)
      if [[ -z "${2:-}" ]] || [[ "$2" =~ ^- ]]; then
        echo "Error: --phase requires a numeric argument" >&2
        exit 1
      fi
      phase_offset="$2"
      shift 2
      ;;
    -c | --char)
      if [[ -z "${2:-}" ]] || [[ "$2" =~ ^- ]]; then
        echo "Error: --char requires a numeric argument" >&2
        exit 1
      fi
      char_offset="$2"
      shift 2
      ;;
    -g | --generate)
      if [[ -z "${2:-}" ]] || [[ "$2" =~ ^- ]]; then
        echo "Error: --generate requires a file argument" >&2
        exit 1
      fi
      generate_file="$2"
      shift 2
      ;;
    -P | --play)
      if [[ -z "${2:-}" ]] || [[ "$2" =~ ^- ]]; then
        echo "Error: --play requires a file argument" >&2
        exit 1
      fi
      play_file="$2"
      shift 2
      ;;
    -h | --help)
      print_usage
      exit 0
      ;;
    -v | --version)
      print_version
      exit 0
      ;;
    -*)
      echo "Error: Unknown option '$1'" >&2
      print_usage
      exit 1
      ;;
    *)
      if [[ -z "$logo_file" ]]; then
        logo_file="$1"
      else
        echo "Error: Multiple files specified" >&2
        exit 1
      fi
      shift
      ;;
    esac
  done
}

check_terminal_support() {
  if [[ -z "${TERM:-}" ]]; then
    return
  fi

  case "$TERM" in
  *-256color | *-truecolor | xterm-kitty | alacritty | foot | wezterm)
    return
    ;;
  esac

  if [[ "${COLORTERM:-}" =~ ^(truecolor|24bit)$ ]]; then
    return
  fi
}

render_frame() {
  local base_hue=$1
  local line_num=0

  tput cup 0 0

  for line in "${logo[@]}"; do
    local line_hue=$((base_hue + line_num * phase_offset))
    local char_num=0

    for ((i = 0; i < ${#line}; i++)); do
      local char="${line:$i:1}"

      if [[ "$char" != " " ]]; then
        local char_hue=$((line_hue + char_num * char_offset))
        simple_hsl_to_rgb "$char_hue"
        printf '\033[38;2;%d;%d;%dm%s' "$rgb_r" "$rgb_g" "$rgb_b" "$char"
      else
        printf '%s' "$char"
      fi

      char_num=$((char_num + 1))
    done

    printf '\033[0m\n'
    line_num=$((line_num + 1))
  done
}

render_frame_to_var() {
  local base_hue=$1
  local line_num=0
  frame_output=""

  for line in "${logo[@]}"; do
    local line_hue=$((base_hue + line_num * phase_offset))
    local char_num=0
    local line_output=""

    for ((i = 0; i < ${#line}; i++)); do
      local char="${line:$i:1}"

      if [[ "$char" != " " ]]; then
        local char_hue=$((line_hue + char_num * char_offset))
        simple_hsl_to_rgb "$char_hue"
        local colored_char
        printf -v colored_char '\033[38;2;%d;%d;%dm%s' "$rgb_r" "$rgb_g" "$rgb_b" "$char"
        line_output+="$colored_char"
      else
        line_output+="$char"
      fi

      char_num=$((char_num + 1))
    done

    frame_output+="${line_output}"$'\033[0m\n'
    line_num=$((line_num + 1))
  done
}

generate_frames() {
  local output_file="$1"
  local frame_count=0

  echo "Generating $total_frames frames to '$output_file'..."

  >"$output_file"

  for ((hue = 0; hue < 360; hue++)); do
    render_frame_to_var "$hue"
    printf '%s\0' "$frame_output" >>"$output_file"
    frame_count=$((frame_count + 1))

    if ((frame_count % 36 == 0)); then
      echo "Progress: $frame_count / $total_frames frames"
    fi
  done

  echo "Done! Generated $frame_count frames to '$output_file'"
}

play_frames() {
  local input_file="$1"

  if [[ ! -f "$input_file" ]]; then
    echo "Error: Frame cache file '$input_file' not found" >&2
    exit 1
  fi

  if [[ ! -r "$input_file" ]]; then
    echo "Error: Cannot read file '$input_file'" >&2
    exit 1
  fi

  local frames=()
  mapfile -d '' -t frames <"$input_file"

  local frame_count=${#frames[@]}

  tput clear
  tput civis

  local frame_index=0

  while true; do
    tput cup 0 0
    printf '%s' "${frames[$frame_index]}"
    frame_index=$(((frame_index + 1) % frame_count))
    sleep "${animation_speed}e-3"
  done
}

main() {
  parse_arguments "$@"
  check_terminal_support
  load_logo

  if [[ -n "$generate_file" ]]; then
    generate_frames "$generate_file"
    exit 0
  fi

  if [[ -n "$play_file" ]]; then
    play_frames "$play_file"
    exit 0
  fi

  tput clear
  tput civis

  local hue=0

  while true; do
    render_frame "$hue"

    hue=$(((hue + 1) % 360))

    sleep "${animation_speed}e-3"
  done
}

main "$@"
