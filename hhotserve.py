#!/usr/bin/env python3
import os
import sys
import time
import argparse
import logging
from http.server import HTTPServer, SimpleHTTPRequestHandler
from threading import Thread
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class ReloadHandler(FileSystemEventHandler):
    def __init__(self, restart_callback):
        self.restart_callback = restart_callback

    def on_modified(self, event):
        if event.is_directory:
            return

        if event.src_path.endswith(('.py', '.html', '.css', '.js')):
            logger.info(f"File modified: {event.src_path}")
            self.restart_callback()

class LoggingHTTPRequestHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, directory=None, **kwargs):
        self.directory = directory
        super().__init__(*args, **kwargs)

    def log_message(self, format, *args):
        logger.info(f"{self.address_string()} - {format % args}")

class AutoReloadServer:
    def __init__(self, host="0.0.0.0", port=8000, directory='.'):
        self.port = port
        self.host = host
        self.directory = directory
        self.server = None
        self.server_thread = None

    def start_server(self):
        os.chdir(self.directory)

        handler = lambda *args, **kwargs: LoggingHTTPRequestHandler(*args, directory=self.directory, **kwargs)

        self.server = HTTPServer((self.host, self.port), handler)
        self.server_thread = Thread(target=self.server.serve_forever)
        self.server_thread.daemon = True
        self.server_thread.start()
        logger.info(f"Server started on http://{self.host}:{self.port}")

    def stop_server(self):
        if self.server:
            self.server.shutdown()
            self.server.server_close()

    def restart_server(self):
        logger.info("Restarting server...")
        self.stop_server()
        time.sleep(0.5)
        self.start_server()

    def run_with_autoreload(self):
        self.start_server()

        event_handler = ReloadHandler(self.restart_server)
        observer = Observer()
        observer.schedule(event_handler, self.directory, recursive=True)
        observer.start()

        try:
            logger.info("Press Ctrl+C to stop the server")
            while True:
                time.sleep(3)
        except KeyboardInterrupt:
            logger.info("Stopping server...")
            observer.stop()
            self.stop_server()

        observer.join()

def main():
    parser = argparse.ArgumentParser(description='HTTP server with auto-reload')
    parser.add_argument('directory', default='.', help='Directory to serve (default: current directory)')
    parser.add_argument('-b', '--bind', type=str, default='0.0.0.0', help="Valid host to bind (default: 0.0.0.0)")
    parser.add_argument('-p', '--port', type=int, default=8000, help='Port to serve on (default: 8000)')
    parser.add_argument('-v', '--verbose', action='store_true', help='Enable verbose logging')

    args = parser.parse_args()

    if args.verbose:
        logging.getLogger().setLevel(logging.INFO)

    try:
        import watchdog
    except ImportError:
        logger.error("ERROR: watchdog package required")
        logger.error("Install with: \n\tpip install watchdog")
        sys.exit(1)

    server = AutoReloadServer(host=args.bind ,port=args.port, directory=args.directory)
    server.run_with_autoreload()

if __name__ == '__main__':
    main()
