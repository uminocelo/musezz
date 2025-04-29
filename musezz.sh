#!/bin/bash

INPUT_DIR="src/scss"
OUTPUT_DIR="src/css"
STYLE="compressed"
SOURCE_MAP=false
WATCH_MODE=false
RECURSIVE=false
FORCE=false

usage() {
  echo "Usage: $0 <input_path> [output_path] [options]"
  echo ""
  echo "Arguments:"
  echo "  <input_path>   Path to the input SCSS file or directory."
  echo "  [output_path]  Path to the output CSS file or directory."
  echo ""
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

check_dependencies() {
  local sass_installed=false
  
  if command_exists "sass"; then
    sass_installed=true
    echo "Using Dart Sass compiler."
  elif command_exists "node-sass"; then
    sass_installed=true
    echo "Using Node Sass compiler."
  fi

  if ! $sass_installed; then
    echo "Error: Neither Dart Sass nor Node Sass is installed."
    echo "Please install one of them to use this script."
    exit 1
  fi
}

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -i|--input)
      INPUT_DIR="$2"
      shift
      shift
      ;;
    -o|--output)
      OUTPUT_DIR="$2"
      shift
      shift
      ;;
    -s|--style)
      STYLE="$2"
      shift
      shift
      ;;
    -m|--source-map)
      SOURCE_MAP=true
      shift
      ;;
    -w|--watch)
      WATCH_MODE=true
      shift
      ;;
    -r|--recursive)
      RECURSIVE=true
      shift
      ;;
    -f|--force)
      FORCE=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $key"
      usage
      exit 1
      ;;
  esac
done

if [ ! -d "$INPUT_DIR"]; then
  echo "Error: No input path specified."
  exit 1
fi

if [ ! -d "$OUTPUT_DIR" ]; then
  echo "Error: No output path specified."
  exit 1
fi

check_dependencies

COMPILER="sass"
if command_exists "sass" && command_exists "node-sass"; then
  COMPILER="node-sass"
fi

convert_file() {
  local input_file="$1"
  local output_file="${input_file/$INPUT_DIR/$OUTPUT_DIR}"
  output_file="${output_file%.scss}.css"

  local output_dir=$(dirname "$output_file")
  if [ ! -d "$output_dir" ]; then
    mkdir -p "$output_dir"
  fi

  if [[ $(basename "$input_file") == "_*" ]]; then
    echo "Skipping partial file: $input_file"
    return
  fi

  if [ -f "$output_file"] && [ "$FORCE" != "true"]; then
    if [ "$input_file" -ot "$output_file"]; then
      echo "Skipping $input_file, output is up to date."
      return
    fi
  fi

  echo "Converting $input_file to $output_file"

  local cmd="$COMPILER"

  if [ "$COMPILER" = "sass" ]; then
    cmd="$cmd $input_file $output_file --style=$STYLE"
    if [ "$SOURCE_MAP" = true ]; then
      cmd="$cmd --source-map"
    fi
  else 
    cmd="$cmd $input_file $output_file --style=$STYLE"
    if [ "$SOURCE_MAP" = true ]; then
      cmd="$cmd --source-map true"
    fi
  fi

  eval "$cmd"

  if [ $? -eq 0]; then
    echo "Successfully converted $input_file to $output_file"
  else
    echo "Error converting $input_file"
  fi
}

process_directory() {
  local dir="$1"

  for file in "$dir"/*.css; do
    if [ -f "$file" ]; then
      convert_file "$file"
    fi
  done

  if [ "$RECURSIVE" = "true" ]; then
    for subdir in "$dir"/*/; do
      if [ -d "$subdir" ]; then
        process_directory "$subdir"
      fi
    done
  fi
}

if [ "$WATCH_MODE" = "true" ]; then
  echo "Starting watch mode for $INPUT_DIR..."

  if command_exists "fswatch"; then
    fswatch -0 -r "$INPUT_DIR" | while read -d "" event; do
      if [[ "$event" == *.scss]]; then
        convert_file "$event"
      fi
    done
  elif command_exists "inotifywait"; then
    while true; then
      inotifywait -r -e modify,create,delete "$INPUT_DIR"
      process_directory "$INPUT_DIR"
    done
  else
    echo "Error: Neither fswatch nor inotifywait is installed."
    echo "Please install one of them to use watch mode."
    echo "Failing back to one-time conversion."
    process_directory "$INPUT_DIR"
  fi
else
  process_directory "$INPUT_DIR"
fi

echo "SCSS conversion completed."
echo "Output files are located in $OUTPUT_DIR"
echo "Done."