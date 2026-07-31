# Hello Kubernetes

[![Build Status](https://diablinux.visualstudio.com/Test/_apis/build/status/diablinux.hello-k8s?branchName=master)](https://diablinux.visualstudio.com/Test/_build/latest?definitionId=1&branchName=master)

A simple flask app to test in docker/kubernetes

## Runtime architecture

This container now runs Flask in production mode using:

- Nginx listening on port 5000
- Gunicorn bound to 127.0.0.1:8000
- Flask app served by Gunicorn workers

## Pull the image

`docker pull diablinux/hello-k8s:0.1`

```text
docker images
REPOSITORY                           TAG                 IMAGE ID            CREATED             SIZE
diablinux/hello-k8s                  0.1                 86e3b494fb42        20 hours ago        120MB
```

## Run the container

```bash
docker run --rm -it -p 5000:5000 86e3b494fb42
```

Build locally:

```bash
docker build -t hello-k8s:local .
```

Run locally:

```bash
docker run --rm -it -p 5000:5000 hello-k8s:local
```

Open your browser at <http://localhost:5000/>.

## License

Licensed under Apache 2.0. Please see [LICENSE](LICENSE) for details.
