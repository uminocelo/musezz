#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/lib/utils.sh"

INPUT_FILE=""
OUTPUT_FILE=""
STYLE="expanded"
SOURCE_MAP=false
VERBOSE=false
DRY_RUN=false

usage() {
  echo "musezz - A simple and flexible SCSS compiler script for your web projects."
  echo "Usage: musezz.sh [OPTIONS] -i <input_file> [ -o <output_file> ]"
  echo ""
  echo "Options:"
  echo "  -i, --input <file>    Input SCSS file"
  echo "  -o, --output <file>   Output CSS file (default: same as input with .css extension)"
  echo "  -s, --style <style>   Output style (default: expanded) (default: expanded)"
  echo "  -m, --source-map      Generate source map"
  echo "  -v, --verbose         Enable verbose output"
  echo "  -d, --dry-run         Process the file without writing output"
  echo "  -h, --help            Display this help message"
  echo ""
  echo "Examples:"
  echo "  musezz.sh -i style.scss -o style.css"
  echo "  musezz.sh -i style.scss --style compressed"
  echo "  musezz.sh -i style.scss --source-map"
  echo "  musezz.sh -i style.scss --verbose"
  echo "  musezz.sh -i style.scss --dry-run"
  echo ""
}

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -i|--input)
      INPUT_FILE="$2"
      shift
      shift
      ;;
    -o|--output)
      OUTPUT_FILE="$2"
      shift
      shift
      ;;
    -s|--style)
      STYLE="$2"
      if [[ ! "$STYLE" =~ ^(expanded|compressed)$ ]]; then
        log_error "Invalid style: $STYLE. Valid options are: expanded, compressed."
        exit 1
      fi
      shift
      shift
      ;;
    -m|--source-map)
      SOURCE_MAP=true
      shift
      ;;
    -v|--verbose)
      VERBOSE=true
      shift
      ;;
    -d|--dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      log_error "Unknown option: $key"
      usage
      exit 1
      ;;
  esac
done

if [ -z "$INPUT_FILE" ]; then
  log_error "Error: Input file is required. Use -i or --input option."
  usage
  exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
  log_error "Error: Input file does not exist: $INPUT_FILE"
  exit 1
fi

if [ -z "$OUTPUT_FILE"]; then
  OUTPUT_FILE="${INPUT_FILE%.scss}.css"
  log_info "Output file not specified. Using default: $OUTPUT_FILE"
fi

process_scss_file() {
  local input_file="$1"
  local output_file="$2"
  
  log_info "Processing SCSS file: $input_file"
  
  local output_dir=$(dirname "$output_file")
  if [ ! -d "$output_dir" ]; then
    log_info "Creating output directory: $output_dir"
    mkdir -p "$output_dir"
  fi

  local scss_content=$(cat "$input_file")

  log_info "Parsing SCSS content..."
  local parsed_content=$(parse_scss "$scss_content" "$STYLE")

  log_info "Converting to CSS..."
  local css_content=$(convert_to_css "$parsed_content" "$STYLE")

  if [ "$DRY_RUN" != "true"]; then
    log_info "Writing output to: $output_file"
    echo "$css_content" > "$output_file"

    if [ "$SOURCE_MAP" = true ]; then
      local map_file="${output_file}.map"
      log_info "Generating source map..."
      generate_source_map "$input_file" "$output_file"

      echo "/*# sourceMappingURL=${output_file}.map */" >> "$output_file"
    fi
  else
    echo "Dry run enabled. Output not written."
    if [ "$VERBOSE" = true ]; then
      log_info "Generated CSS:"
      echo "$css_content"
    fi
  fi

  log_success "SCSS to CSS conversion completed!"
}

process_scss_file "$INPUT_FILE" "$OUTPUT_FILE"