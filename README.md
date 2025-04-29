# Musezz

A simple and flexible SCSS compiler script for your web projects.

## Overview

Musezz is a Bash script that simplifies compiling SCSS files to CSS. It supports both Dart Sass and Node Sass, works with file watching, and offers various customization options.

## Features

- Supports both **Dart Sass** and **Node Sass**
- **Watch mode** for automatic compilation when files change
- **Recursive directory** processing
- **Skips partial files** (beginning with `_`)
- **Multiple style outputs** (compressed, expanded, etc.)
- **Source map** generation
- **Force compilation** option

## Requirements

You need one of the following installed:
- [Dart Sass](https://sass-lang.com/install)
- [Node Sass](https://www.npmjs.com/package/node-sass)

For watch mode, you'll need:
- **macOS**: [fswatch](https://github.com/emcrisostomo/fswatch)
- **Linux**: [inotifywait](https://github.com/inotify-tools/inotify-tools)

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/musezz.git
   ```

2. Make the script executable:
   ```bash
   chmod +x musezz.sh
   ```

## Usage

Basic usage:
```bash
./musezz.sh -i <input_directory> -o <output_directory>
```

### Options

| Option | Description |
|--------|-------------|
| `-i, --input <dir>` | Input directory containing SCSS files |
| `-o, --output <dir>` | Output directory for compiled CSS |
| `-s, --style <style>` | Output style (compressed, expanded, etc.) |
| `-m, --source-map` | Generate source maps |
| `-w, --watch` | Watch for file changes |
| `-r, --recursive` | Process directories recursively |
| `-f, --force` | Force compilation even if files are up-to-date |
| `-h, --help` | Show help information |

### Examples

Compile a directory of SCSS files:
```bash
./musezz.sh -i src/scss -o src/css
```

Watch for changes and compile automatically:
```bash
./musezz.sh -i src/scss -o src/css -w
```

Compile with expanded style and source maps:
```bash
./musezz.sh -i src/scss -o src/css -s expanded -m
```

## License

MIT License

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.