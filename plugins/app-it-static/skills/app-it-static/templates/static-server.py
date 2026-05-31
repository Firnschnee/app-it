#!/usr/bin/env python3
# Tiny zero-dependency static file server for app-it-static.
#
# Serves a *finished* build directory (dist/ build/ out/ ...) over
# http://127.0.0.1:PORT with single-page-app fallback, so a finished app runs
# with ~15 MB of RAM instead of the 300-700 MB a dev server (bundler +
# file-watcher + transpiler held in memory) costs. This is the static analog of
# wrapper.swift: small, shipped, no install — Python 3 is already required by
# this toolchain (Xcode CLT ships it; the build scripts shell /usr/bin/python3).
#
# WHY NOT `python3 -m http.server`:
#   - It has no SPA history fallback: deep links into a client-side router
#     (React Router, Vue Router, SvelteKit) 404 because nothing rewrites unknown
#     routes to index.html.
#   - Its MIME guesses are stale on some systems (.mjs/.wasm served as
#     octet-stream → the browser refuses the module/wasm). We pin the few that
#     matter.
#
# Usage:
#   STATIC_DIR=/abs/path/to/dist PORT=4100 ./static-server.py
#   ./static-server.py /abs/path/to/dist 4100
#
# Binds 127.0.0.1 ONLY — never 0.0.0.0. This is a local launcher, not a host.

import os
import sys
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

# Pin the content types that browsers are strict about and older mimetypes DBs
# get wrong. Everything else falls through to the stdlib guesser.
EXTRA_TYPES = {
    ".js":          "text/javascript",
    ".mjs":         "text/javascript",
    ".wasm":        "application/wasm",
    ".json":        "application/json",
    ".map":         "application/json",
    ".webmanifest": "application/manifest+json",
}


class StaticHandler(SimpleHTTPRequestHandler):
    """SPA-aware static handler rooted at a fixed directory (set via partial)."""

    def guess_type(self, path):
        _, ext = os.path.splitext(path)
        return EXTRA_TYPES.get(ext.lower()) or super().guess_type(path)

    def send_head(self):
        # SPA history fallback, the standard (connect-history-api-fallback) way:
        # if the path maps to no real file or directory AND it's a page navigation
        # (the browser sent `Accept: text/html`), serve index.html so the
        # client-side router can take over. Asset requests — scripts, fetch,
        # images — don't ask for text/html, so a genuinely missing asset still
        # 404s and a broken build isn't masked as the home page. Keying on Accept
        # (not a filename-extension guess) is what lets a route whose last segment
        # contains a dot, e.g. /report/2024.q1, fall back correctly while
        # /assets/missing.js still 404s. translate_path() blocks "../" escapes.
        path = self.translate_path(self.path)
        if not os.path.exists(path) and "text/html" in self.headers.get("Accept", ""):
            self.path = "/index.html"
        return super().send_head()

    def end_headers(self):
        # Local snapshot: discourage caching so a desktop:rebuild shows up on the
        # next reload instead of serving a stale chunk from the WebKit cache.
        self.send_header("Cache-Control", "no-cache")
        super().end_headers()

    def log_message(self, fmt, *args):
        # One terse line per request to the launcher's server.log (stderr).
        sys.stderr.write("%s - %s\n" % (self.address_string(), fmt % args))


def main():
    directory = os.environ.get("STATIC_DIR") or (sys.argv[1] if len(sys.argv) > 1 else ".")
    port_str = os.environ.get("PORT") or (sys.argv[2] if len(sys.argv) > 2 else "4100")
    directory = os.path.abspath(directory)

    if not os.path.isdir(directory):
        sys.stderr.write("static-server: directory not found: %s\n" % directory)
        sys.exit(1)
    try:
        port = int(port_str)
    except ValueError:
        sys.stderr.write("static-server: invalid PORT: %s\n" % port_str)
        sys.exit(1)

    handler = partial(StaticHandler, directory=directory)
    httpd = ThreadingHTTPServer(("127.0.0.1", port), handler)
    sys.stderr.write("static-server: serving %s at http://127.0.0.1:%d\n" % (directory, port))
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        httpd.server_close()


if __name__ == "__main__":
    main()
