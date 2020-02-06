# Hello Kubernetes

A simple flask app to test in docekr/kubernetes

**Pull the image**

`$ docker pull diablinux/hello-k8s:0.1`

```$ docker images
REPOSITORY                           TAG                 IMAGE ID            CREATED             SIZE
diablinux/hello-k8s                  0.1                 86e3b494fb42        20 hours ago        120MB
```

**Run the container**
```
$ docker run --rm -it -p 5000:5000 86e3b494fb42
 * Serving Flask app "hello" (lazy loading)
 * Environment: production
   WARNING: This is a development server. Do not use it in a production deployment.
   Use a production WSGI server instead.
 * Debug mode: off
 * Running on http://0.0.0.0:5000/ (Press CTRL+C to quit)
172.17.0.1 - - [05/Feb/2020 07:07:09] "GET / HTTP/1.1" 200 -
```

Open your browser http://localhost:5000/



# License

Licensed under Apache 2.0. Please see [LICENSE](LICENSE) for details.
