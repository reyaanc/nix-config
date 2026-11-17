import functools
import http.server
import os
import subprocess


class Handler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cache-Control", "no-cache")
        super().end_headers()


handler = functools.partial(Handler, directory=os.environ["WALLPAPERS"])
server = http.server.ThreadingHTTPServer(("127.0.0.1", 8484), handler)
# At login Plash can load the page before this server is listening and never retries, so it's told to reload once the port is up
if subprocess.run(["pgrep", "-xq", "Plash"]).returncode == 0:
    subprocess.run(["open", "-g", "plash:reload"])
server.serve_forever()
