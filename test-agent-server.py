#!/usr/bin/env python3
"""Simple HTTP server that serves an agent card for testing"""

from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import os

class AgentCardHandler(BaseHTTPRequestHandler):
    def _add_security_headers(self):
        """Add security headers to response"""
        self.send_header('X-Content-Type-Options', 'nosniff')
        self.send_header('X-Frame-Options', 'DENY')
        self.send_header('X-XSS-Protection', '1; mode=block')
    
    def do_GET(self):
        # Serve agent card at standard location
        if self.path in ['/.well-known/agent-card.json', '/agent-card.json']:
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self._add_security_headers()
            self.end_headers()
            
            # Load the safe agent card and update URL to match this server
            with open('examples/safe-agent-card.json', 'r') as f:
                agent_card = json.load(f)
            
            # Update URL to match this endpoint
            agent_card['url'] = f'http://localhost:{self.server.server_port}'
            
            self.wfile.write(json.dumps(agent_card, indent=2).encode())
        
        # Health endpoint
        elif self.path in ['/health', '/healthz']:
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self._add_security_headers()
            self.end_headers()
            self.wfile.write(b'{"status": "healthy"}')
        
        # Root endpoint
        elif self.path == '/':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self._add_security_headers()
            self.end_headers()
            response = {
                'message': 'Test Agent Endpoint',
                'agent_card': '/.well-known/agent-card.json',
                'health': '/health'
            }
            self.wfile.write(json.dumps(response, indent=2).encode())
        
        else:
            self.send_response(404)
            self._add_security_headers()
            self.end_headers()
    
    def log_message(self, format, *args):
        # Suppress default logging
        pass

if __name__ == '__main__':
    port = 8000
    print(f"🚀 Test Agent Server starting on http://localhost:{port}")
    print(f"📋 Agent card: http://localhost:{port}/.well-known/agent-card.json")
    print(f"❤️  Health check: http://localhost:{port}/health")
    print(f"\nPress CTRL+C to stop\n")
    
    server = HTTPServer(('localhost', port), AgentCardHandler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n\n👋 Server stopped")
