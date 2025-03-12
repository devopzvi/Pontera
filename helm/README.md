# NGINX Helm Chart
## Install on EKS
Ensure your `kubectl` and `helm` are configured for your EKS cluster:
```sh
aws eks update-kubeconfig --region <region> --name <cluster-name>
helm install my-nginx ./nginx-helm-chart
```

## Rolling Upgrade
To deploy a new version (e.g., `1.27.5`):
```sh
helm upgrade my-nginx ./nginx-helm-chart --set image.tag=1.27.5
```
Verify rollout status:
```sh
kubectl rollout status deployment/my-nginx-nginx
```
## Rollback
```sh
helm history my-nginx
```
```sh
helm rollback my-nginx 1
```
Check the pods to confirm rollback:
```sh
kubectl get pods
```
    