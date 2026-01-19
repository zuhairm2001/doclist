package main

import (
	"fmt"
	"html"
	"io/fs"
	"os"
	"path/filepath"
	"strings"
)

// dirEntry holds files for a directory
type dirEntry struct {
	name  string   // cleaned display name
	files []string // cleaned file names
}

func main() {
	if len(os.Args) < 2 {
		fmt.Fprintln(os.Stderr, "Usage: doclist <directory>")
		fmt.Fprintln(os.Stderr, "Converts a directory listing to WordPress-ready HTML format")
		os.Exit(1)
	}

	targetDir := os.Args[1]

	// Validate directory exists
	info, err := os.Stat(targetDir)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
	if !info.IsDir() {
		fmt.Fprintf(os.Stderr, "Error: '%s' is not a directory\n", targetDir)
		os.Exit(1)
	}

	// Get absolute path
	absPath, err := filepath.Abs(targetDir)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error resolving path: %v\n", err)
		os.Exit(1)
	}

	// Walk directory and collect entries
	entries, err := walkDirectory(absPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error walking directory: %v\n", err)
		os.Exit(1)
	}

	// Generate HTML
	htmlOutput := renderHTML(entries)

	// Write to tmp.html in the parent directory of the target
	parentDir := filepath.Dir(absPath)
	outputPath := filepath.Join(parentDir, "tmp.html")
	err = os.WriteFile(outputPath, []byte(htmlOutput), 0644)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error writing output: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Done! Output saved to: %s\n", outputPath)
}

// walkDirectory walks the directory tree and collects entries
// Returns entries in the order they are encountered (preserving filesystem order)
func walkDirectory(root string) ([]dirEntry, error) {
	// Map to collect files per directory
	dirFiles := make(map[string][]string)
	// Slice to track directory order
	var dirOrder []string
	// Set to track which directories we've seen
	dirSeen := make(map[string]bool)

	rootName := filepath.Base(root)

	err := filepath.WalkDir(root, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		name := d.Name()

		// Skip hidden files and directories
		if isHidden(name) {
			if d.IsDir() {
				return filepath.SkipDir
			}
			return nil
		}

		if d.IsDir() {
			// Get relative path from root for the directory key
			relPath, _ := filepath.Rel(root, path)
			if relPath == "." {
				relPath = rootName
			} else {
				relPath = filepath.Join(rootName, relPath)
			}

			if !dirSeen[relPath] {
				dirSeen[relPath] = true
				dirOrder = append(dirOrder, relPath)
				dirFiles[relPath] = []string{}
			}
		} else {
			// It's a file - add to parent directory
			parentPath, _ := filepath.Rel(root, filepath.Dir(path))
			if parentPath == "." {
				parentPath = rootName
			} else {
				parentPath = filepath.Join(rootName, parentPath)
			}

			// Ensure parent directory is tracked
			if !dirSeen[parentPath] {
				dirSeen[parentPath] = true
				dirOrder = append(dirOrder, parentPath)
				dirFiles[parentPath] = []string{}
			}

			cleanedName := cleanName(name)
			dirFiles[parentPath] = append(dirFiles[parentPath], cleanedName)
		}

		return nil
	})

	if err != nil {
		return nil, err
	}

	// Build result slice in order
	var entries []dirEntry
	for _, dirPath := range dirOrder {
		files := dirFiles[dirPath]
		if len(files) > 0 { // Only include directories that have files
			// Clean the directory name for display
			// Use just the last component of the path for display
			displayName := filepath.Base(dirPath)
			cleanedDirName := cleanDirName(displayName)

			entries = append(entries, dirEntry{
				name:  cleanedDirName,
				files: files,
			})
		}
	}

	return entries, nil
}

// isHidden checks if a file/directory name starts with a dot
func isHidden(name string) bool {
	return strings.HasPrefix(name, ".")
}

// cleanName cleans a filename: strips extension, replaces _ and - with spaces
func cleanName(name string) string {
	// Strip extension
	ext := filepath.Ext(name)
	if ext != "" {
		name = strings.TrimSuffix(name, ext)
	}

	// Replace underscores and hyphens with spaces
	name = strings.ReplaceAll(name, "_", " ")
	name = strings.ReplaceAll(name, "-", " ")

	// Trim any leading/trailing whitespace
	name = strings.TrimSpace(name)

	return name
}

// cleanDirName cleans a directory name: replaces _ and - with spaces
func cleanDirName(name string) string {
	// Replace underscores and hyphens with spaces
	name = strings.ReplaceAll(name, "_", " ")
	name = strings.ReplaceAll(name, "-", " ")

	// Trim any leading/trailing whitespace
	name = strings.TrimSpace(name)

	return name
}

// renderHTML generates the HTML output from directory entries
func renderHTML(entries []dirEntry) string {
	var sb strings.Builder

	for i, entry := range entries {
		// Write directory header
		sb.WriteString("<h3>")
		sb.WriteString(html.EscapeString(entry.name))
		sb.WriteString("</h3>\n")

		// Write file list
		sb.WriteString("<ul>\n")
		for _, file := range entry.files {
			// Using space + tab to match the example format
			sb.WriteString(" \t<li>")
			sb.WriteString(html.EscapeString(file))
			sb.WriteString("</li>\n")
		}
		sb.WriteString("</ul>\n")

		// Add blank line between sections (except after last)
		if i < len(entries)-1 {
			// No extra blank line needed based on the example
		}
	}

	return sb.String()
}
