#!/usr/bin/env python

import os
import datetime

from flask import Flask, jsonify

app = Flask(__name__)


@app.route("/", methods=["GET"])
def hello():
    return jsonify({
        'message': "Hello from Kubernetes!",
        'hostname': os.getenv("HOSTNAME"),
        'time': datetime.datetime.now().isoformat()
    })


@app.route("/health", methods=["GET", "HEAD"])
def health():
    return "OK!", 200


def main():
    app.run(debug=False, host="0.0.0.0")


if __name__ == "__main__":
    main()
