# [alex.gondek.ca](http://alex.gondek.ca/)

My personal homepage, plus various posts and galleries.

**Build Requirements**
- `go` Language Toolchain (v1.25+)
- `just` command runner (see [justfile](./justfile))
- `imagemagick` (for `identify` and `mogrify` commands)
- (optional) `busybox` and `inotifywait` (for `just watch_serve`)

The site uses Go's HTML templating to generate a static site. The output, plus any static files,
are stored in `./docs` to take advantage of [GitHub Page's](https://docs.github.com/en/pages)
feature to host/deploy from that directory.

**Deployment**
1. Run `just build`
2. Commit and push changes.
