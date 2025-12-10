setup:
    bundle config set --local path 'vendor/bundle'
    bundle install

prepare_photos:
    #!/usr/bin/env bash
    find "assets/media/photos" -type f -name "*.jpg" | while read -r photo; do
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
    find "assets/media/photos" -type f -name "*.jpg" | while read -r photo; do
        rel_path="${photo#assets/media/photos}"
        thumb_path="assets/media/thumbnails/$rel_path"
        mkdir -p "$(dirname "$thumb_path")"

        # A makefile would be a good fit here! But I'll stick with justfile...
        if [ ! -f "$thumb_path" ] || [ "$photo" -nt "$thumb_path" ]; then
            echo "Generating thumbnail: $thumb_path"
            convert "$photo" -resize 200x200 "$thumb_path"
        fi
    done

build: prepare_photos make_thumbnails
    rm -rf _site
    bundle exec jekyll build

serve: build
    bundle exec jekyll serve --livereload
