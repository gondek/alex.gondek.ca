export OUTPUT_DIR := "docs"

prepare_photos:
    #!/usr/bin/env bash
    find "$OUTPUT_DIR/media/photos" -type f -name "*.jpg" | while read -r photo; do
        height=$(identify -format "%h" "$photo")
        metadata=$(identify -format "%[EXIF:*]" "$photo")
        truncated_metadata="${metadata//$'\n'/ }"
        truncated_metadata="${truncated_metadata:0:120}"

        if [ "$height" -gt 2000 ] || [ -n "$metadata" ]; then
            echo "Modifying: $photo (height=$height, metadata=$truncated_metadata...)"
            mogrify -strip -resize 'x2000>' "$photo"
        fi
    done

make_thumbnails: prepare_photos
    #!/usr/bin/env bash
    find "$OUTPUT_DIR/media/photos" -type f -name "*.jpg" | while read -r photo; do
        rel_path="${photo#$OUTPUT_DIR/media/photos/}"
        thumb_path="$OUTPUT_DIR/media/thumbnails/$rel_path"
        mkdir -p "$(dirname "$thumb_path")"

        # A makefile would be a good fit here! But I'll stick with justfile...
        if [ ! -f "$thumb_path" ] || [ "$photo" -nt "$thumb_path" ]; then
            echo "Generating thumbnail: $thumb_path"
            convert "$photo" -resize 200x200 "$thumb_path"
        fi
    done

build: prepare_photos make_thumbnails
    go run src/build_pages.go

format:
    gofmt -w ./src

watch_serve: build
    #!/bin/sh
    trap "PID=\$(lsof -ti tcp:8080); if [ -n \"\$PID\" ]; then kill \$PID; echo '\nStopping server (PID: '\$PID')'; fi; exit 0;" INT
    busybox httpd -p 8080 -h "$OUTPUT_DIR" && echo "Starting server at http://localhost:8080/"
    inotifywait --recursive --monitor --event close_write --event create \
    --format '%T: %w%f %e' --timefmt '%H:%M:%S' src --exclude ".*~" | while read -r file; do
        echo "$file -> Rebuilding..."
        just --quiet build
    done
