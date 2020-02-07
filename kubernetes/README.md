To test a deployment in kubernetes

Create the deployment

```
> kubectl create -f .\deployment.yaml
deployment.apps/hello-k8s created
```

Wait until deplyment is available

```
> kubectl get deploy
NAME        READY   UP-TO-DATE   AVAILABLE   AGE
hello-k8s   1/1     1            1           13s
```

Verify Pods is running

```
kubectl get pods -A
NAMESPACE     NAME                                     READY   STATUS    RESTARTS   AGE
default       hello-k8s-7696fc9f6-zrltc                1/1     Running   0          55s
```

Create the service

```
> kubectl create -f .\service.yaml
service/hello-kubernetes created
```

Validate the service 

```
> kubectl get svc
NAME         TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
hello-k8s    LoadBalancer   10.103.208.108   localhost     80:30618/TCP   3s
```

Open your browser http://localhost/

Health check http://localhost/health

Update the port in the service manifest as needed.