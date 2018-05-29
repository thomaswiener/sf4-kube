kubectl apply -f deployment.yaml
kubectl expose deployment go-deployment --type="LoadBalancer"