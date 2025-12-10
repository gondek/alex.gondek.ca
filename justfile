export OUTPUT_DIR := "docs"

build:
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
