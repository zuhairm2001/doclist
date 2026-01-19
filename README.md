# doclist

A CLI tool that converts a directory listing to WordPress-ready HTML format.

## Installation

### Linux / macOS

```bash
curl -fsSL https://raw.githubusercontent.com/zuhairm2001/doclist/main/install.sh | bash
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/zuhairm2001/doclist/main/install.ps1 | iex
```

### Manual Download

Download the latest binary from the [Releases](https://github.com/zuhairm2001/doclist/releases) page:

| Platform | Binary |
|----------|--------|
| Linux (x64) | `doclist-linux-amd64` |
| Linux (ARM64) | `doclist-linux-arm64` |
| Windows (x64) | `doclist-windows-amd64.exe` |

### Build from Source

Requires Go 1.21+

```bash
git clone https://github.com/zuhairm2001/doclist.git
cd doclist
go build -o doclist .
```

## Usage

```bash
doclist <directory>
```

The tool will:
1. Walk the directory tree
2. Collect all non-hidden files organized by subdirectory
3. Generate WordPress-ready HTML with `<h3>` headings and `<ul>` lists
4. Save the output to `<dirname>.html` in the parent directory

### Example

```bash
doclist ./my-documents
```

Output saved to `./my-docume.html` (first 10 characters of directory name).

### Sample Output

```html
<h3>Reports</h3>
<ul>
 	<li>Annual Report 2024</li>
 	<li>Q1 Summary</li>
</ul>
<h3>Invoices</h3>
<ul>
 	<li>Invoice 001</li>
 	<li>Invoice 002</li>
</ul>
```

## Features

- Skips hidden files and directories (starting with `.`)
- Cleans filenames: removes extensions, replaces `_` and `-` with spaces
- HTML-escapes all content for safe WordPress embedding
- Preserves directory traversal order

## License

MIT
