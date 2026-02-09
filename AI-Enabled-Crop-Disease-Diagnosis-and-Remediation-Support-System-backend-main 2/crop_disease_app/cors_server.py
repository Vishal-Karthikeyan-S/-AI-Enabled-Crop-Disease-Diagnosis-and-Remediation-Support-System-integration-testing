from http.server import HTTPServer, SimpleHTTPRequestHandler
import sys
import os

class CORSRequestHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cross-Origin-Opener-Policy', 'same-origin')
        self.send_header('Cross-Origin-Embedder-Policy', 'require-corp')
        self.send_header('Access-Control-Allow-Origin', '*')
        super().end_headers()

if __name__ == '__main__':
    web_dir = os.path.join(os.getcwd(), 'build/web')
    if os.path.exists(web_dir):
        os.chdir(web_dir)
        print(f"Serving content from {web_dir}")
    else:
        print(f"Warning: {web_dir} not found. Serving current directory.")

    port = int(sys.argv[1]) if len(sys.argv) > 1 else 3000
    server_address = ('', port)
    httpd = HTTPServer(server_address, CORSRequestHandler)
    print(f"Serving with CORS headers on port {port}")
    httpd.serve_forever()
