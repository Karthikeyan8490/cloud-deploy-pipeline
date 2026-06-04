from flask import Flask, jsonify
import os
import socket

app = Flask(__name__)

@app.route("/")
def hello():
    return """
    <!DOCTYPE html>
    <html>
    <head><title>Hello World - CI/CD Pipeline</title>
    <style>
        body { font-family: Arial, sans-serif; display: flex; justify-content: center;
               align-items: center; height: 100vh; margin: 0; background: #0f172a; color: white; }
        .card { text-align: center; padding: 3rem; border-radius: 12px;
                background: #1e293b; box-shadow: 0 20px 60px rgba(0,0,0,0.4); max-width: 600px; }
        h1 { font-size: 2.5rem; margin-bottom: 1rem; }
        .badge { display: inline-block; background: #22c55e; color: white;
                 padding: 4px 12px; border-radius: 999px; font-size: 0.85rem; margin-top: 1rem; }
        p { color: #94a3b8; }
    </style>
    </head>
    <body>
      <div class="card">
        <h1>🚀 Hello World!</h1>
        <p>Deployed via Automated CI/CD Pipeline</p>
        <p>Flask + Docker + Nginx + EC2 + Terraform + Ansible</p>
        <span class="badge">✅ Live</span>
      </div>
    </body>
    </html>
    """

@app.route("/health")
def health():
    return jsonify({
        "status": "healthy",
        "hostname": socket.gethostname(),
        "version": os.getenv("APP_VERSION", "1.0.0")
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)
