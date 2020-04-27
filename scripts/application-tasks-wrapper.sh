#!/bin/bash

build-image-in-minikube() {
  eval $(minikube docker-env)
  docker build -f src/main/docker/Dockerfile.jvm -t docker.pkg.github.com/explorviz/istio-playground/jvm:latest .
}

deploy() {
  kubectl create namespace quarkus &
  kubectl create namespace foo &
  
  echo "Delete old version."
  kubectl delete -f src/test/resources/kube/quarkus/web-app/other-ns-app.yaml
  kubectl delete -f src/test/resources/kube/quarkus/web-app/web-app.yaml
  kubectl delete -f src/test/resources/kube/quarkus/web-app/rest-app.yaml

  echo "Deploy new version."
  kubectl apply -f src/test/resources/kube/quarkus/web-app/other-ns-app.yaml
  kubectl apply -f src/test/resources/kube/quarkus/web-app/web-app.yaml
  kubectl apply -f src/test/resources/kube/quarkus/web-app/rest-app.yaml

  INGRESS_HOST=$(minikube ip)
  INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
  echo "##########################################################################"
  echo "Application started: http://$INGRESS_HOST:$INGRESS_PORT/login.html"
  echo "##########################################################################"
}

$1
