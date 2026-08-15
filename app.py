from flask import Flask, jsonify

app = Flask(__name__)


@app.route("/")
def index():
    return jsonify({"status": "ok", "service": "myapp"})


@app.route("/health")
def health():
    """Used by Docker HEALTHCHECK and by the pipeline to confirm the app is up before DAST scans it."""
    return jsonify({"status": "healthy"}), 200


if __name__ == "__main__":
    # debug=False is required — Flask's debugger exposes a remote code
    # execution surface if left on in anything resembling production.
    app.run(host="0.0.0.0", port=8080, debug=False)
