import os
import datetime

from flask import Flask, jsonify

app = Flask(__name__)


@app.after_request
def add_response_headers(response):
    response.headers["X-App"] = "flask"
    return response


@app.route("/", methods=["GET"])
def hello():
    return jsonify({
        'message': "Hello from Kubernetes!",
        'hostname': os.getenv("HOSTNAME"),
        'time': datetime.datetime.now(datetime.timezone.utc).isoformat()
    })


@app.route("/health", methods=["GET", "HEAD"])
def health():
    return "OK!", 200


def main():
    app.run(debug=False, host="0.0.0.0", port=int(os.getenv("PORT", "5000")))


if __name__ == "__main__":
    main()
