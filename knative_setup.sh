#!/bin/bash

### NOTICE: IT IS BEST IF YOU RUN EACH COMMAND ONE BY ONE INSTEAD OF RUNNING THIS SCRIPT AS A WHOLE
### THIS IS SO YOU UNDERSTAND WHAT EACH COMMAND IS DOING

### knative cluster setup (source: https://github.com/knative/serving/blob/main/DEVELOPMENT.md)

# cd into the serving directory
# check if the directory is serving
if [ ! -d "serving" ]; then
    echo "serving directory not found, please cd into the serving directory"
    exit 1
fi

# create a new cluster
kind create cluster -n knative

# apply certs
kubectl apply -f ./third_party/cert-manager-latest/cert-manager.yaml
kubectl wait --for=condition=Established --all crd
kubectl wait --for=condition=Available -n cert-manager --all deployments

# apply crds
ko apply --selector knative.dev/crd-install=true -Rf config/core/
kubectl wait --for=condition=Established --all crd
ko apply -Rf config/core/

# verify that the pods are running
kubectl -n knative-serving get pods

# apply kourier (Source: https://github.com/knative-sandbox/net-kourier)
kubectl apply -f ./third_party/kourier-latest/kourier.yaml
kubectl patch configmap/config-network \
  -n knative-serving \
  --type merge \
  -p '{"data":{"ingress.class":"kourier.ingress.networking.knative.dev"}}'

# apply networking istio
kubectl patch configmap/config-domain \
  -n knative-serving \
  --type merge \
  -p '{"data":{"127.0.0.1.nip.io":""}}'

# port mapping (run in a separate terminal, MUST ALWAYS BE RUNNING FOR PORT FORWARDING)
# kubectl port-forward --namespace kourier-system $(kubectl get pod -n kourier-system -l "app=3scale-kourier-gateway" --output=jsonpath="{.items[0].metadata.name}") 8080:8080 19000:9000 8443:8443

# command to test deployed app
# curl -v -H "Host: helloworld-go.default.127.0.0.1.nip.io" http://localhost:8080


### prometheus monitoring setup (Source: https://adamtheautomator.com/prometheus-kubernetes/)
kubectl create namespace monitoring

# prometheus setup
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring -f prometheus-values.yaml

# apply service monitors for knative
kubectl apply -f https://raw.githubusercontent.com/knative-sandbox/monitoring/main/servicemonitor.yaml

# confirm your kube-prometheus stack deployment
kubectl get pods -n monitoring

# access the prometheus instance
kubectl get svc -n monitoring

# use the following command start port forwarding (in a different terminal) - accessed via http://localhost:9090
# kubectl port-forward svc/prometheus-kube-prometheus-prometheus -n monitoring 9090

### grafana setup (Source: https://adamtheautomator.com/prometheus-kubernetes/)
kubectl get secret -n monitoring prometheus-grafana -o yaml

# Decode and print the username (retrieve the value of the key admin-user)
# echo YOUR_USERNAME | base64 --decode
# Decode and print the password (retrieve the value of the key admin-password)
# echo YOUR_PASSWORD | base64 --decode

# access the grafana instance (in a different terminal) - accessed via http://localhost:3000 (user: admin, password: prom-operator)
# kubectl port-forward svc/prometheus-grafana -n monitoring 3000:80

# update the grafana datasource and upload the below dashboards (Source: https://github.com/knative-sandbox/monitoring/tree/main/grafana)
# Dashboard: knative-revision-cpu-memory-metrics.json
# Dashboard: knative-serving-http-requests.json


### delete the cluster (only do this for cleanup)

# ko delete --ignore-not-found=true \
#  -Rf config/core/ \
#  -f ./third_party/kourier-latest/kourier.yaml \
#  -f ./third_party/cert-manager-latest/cert-manager.yaml

# kind delete cluster -n knative

echo "knative setup with prometheus + graphana complete"





