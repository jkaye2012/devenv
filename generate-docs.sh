#!/usr/bin/env bash

set -euo pipefail

SRC_DIR="src"
DOCS_DIR="docs/lib"

mkdir -p "$DOCS_DIR"

find "$SRC_DIR" -name "*.nix" -type f | while read -r nix_file; do
    rel_path="${nix_file#"$SRC_DIR/"}"
    
    category_path="${rel_path%.nix}"
    category_name=$(basename "$category_path")
    
    output_dir="$DOCS_DIR/$(dirname "$category_path")"
    mkdir -p "$output_dir"
    
    output_file="$DOCS_DIR/${category_path}.md"
    echo "Generating documentation for $nix_file -> $output_file"
    
    nixdoc \
        --file "$nix_file" \
        --category "$category_name" \
        --description "lib.$category_name: $(head -2 "$nix_file" | tail -1 | xargs)" \
        --anchor-prefix "" \
        > "$output_file"
done

echo "Documentation generation complete!"
