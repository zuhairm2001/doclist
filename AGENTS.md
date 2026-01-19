# AGENTS.md - Coding Agent Instructions for doclist

This document provides instructions for AI coding agents working in this repository.

## Project Overview

**doclist** is a Go CLI tool that converts a directory listing to WordPress-ready HTML format. It walks a directory tree, collects file information, and outputs formatted HTML with directory headings and file lists.

- **Language**: Go 1.25.5
- **Module**: `github.com/zuhairm2001/doclist`
- **Dependencies**: Standard library only
- **Structure**: Single-file project (`main.go`)

## Build/Run/Test Commands

```bash
# Build
go build                    # Build binary
go build -o doclist         # Build with specific output name

# Run
go run main.go <directory>  # Run directly
./doclist <directory>       # Run built binary

# Test
go test ./...               # Run all tests
go test -v ./...            # Verbose output
go test -v -run TestName    # Run single test by name
go test -v -run "Pattern.*" # Run tests matching pattern
go test -cover ./...        # Run with coverage

# Lint/Format
go fmt ./...                # Format all files
go vet ./...                # Static analysis
```

## Code Style Guidelines

### Imports

Group imports: standard library first, then external packages.

```go
import (
    "fmt"
    "os"
    "strings"
)
```

### Formatting

- Tabs for indentation (Go standard)
- Single blank line between functions
- ~100 character line length (soft limit)

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Private functions | lowerCamelCase | `walkDirectory`, `cleanName` |
| Public functions | UpperCamelCase | `WalkDirectory` |
| Variables | lowerCamelCase | `absPath`, `dirFiles` |
| Packages | lowercase | `main`, `filepath` |

### Function Documentation

Comment above function starting with function name:

```go
// walkDirectory walks the directory tree and collects entries
func walkDirectory(root string) ([]dirEntry, error) {
```

### Error Handling

- Check errors immediately after each call
- Use `fmt.Fprintf(os.Stderr, ...)` for error output
- Return errors rather than panicking
- Use `os.Exit(1)` only in `main()` for fatal errors

```go
info, err := os.Stat(targetDir)
if err != nil {
    fmt.Fprintf(os.Stderr, "Error: %v\n", err)
    os.Exit(1)
}
```

### String Building

Use `strings.Builder` for efficient concatenation:

```go
var sb strings.Builder
sb.WriteString("<h3>")
sb.WriteString(html.EscapeString(entry.name))
sb.WriteString("</h3>\n")
```

### HTML Output

Always escape user-provided content with `html.EscapeString()`.

## File Structure

```
doclist-proj/
├── AGENTS.md       # This file
├── go.mod          # Go module definition
├── main.go         # All source code
└── main_test.go    # Tests (create when needed)
```

## Key Functions

| Function | Purpose |
|----------|---------|
| `main()` | Entry point, CLI argument handling |
| `walkDirectory(root)` | Traverses directory tree, collects entries |
| `isHidden(name)` | Checks if file/dir is hidden (starts with `.`) |
| `cleanName(name)` | Strips extension, replaces `_`/`-` with spaces |
| `cleanDirName(name)` | Replaces `_`/`-` with spaces in dir names |
| `renderHTML(entries)` | Generates WordPress-ready HTML output |

## Testing Patterns

Use table-driven tests:

```go
func TestCleanName(t *testing.T) {
    tests := []struct {
        input    string
        expected string
    }{
        {"file_name.txt", "file name"},
        {"some-file.pdf", "some file"},
    }
    
    for _, tt := range tests {
        result := cleanName(tt.input)
        if result != tt.expected {
            t.Errorf("cleanName(%q) = %q, want %q", tt.input, result, tt.expected)
        }
    }
}
```

## Common Patterns

1. **Map + slice for ordered iteration**: Map for lookups, slice for order
2. **filepath.WalkDir**: Standard directory traversal
3. **filepath.SkipDir**: Skip hidden directories
4. **filepath.Rel()**: Display-friendly relative paths

## Do's and Don'ts

**Do:**
- Run `go fmt ./...` before committing
- Run `go vet ./...` to catch issues
- Use standard library packages
- Handle all errors explicitly
- Write table-driven tests

**Don't:**
- Add external dependencies without discussion
- Use `panic()` for error handling
- Ignore errors with `_`
- Use global mutable state
