#!/bin/bash

build-image-in-minikube() {
  eval $(minikube docker-env)
  docker build -f src/main/docker/Dockerfile.jvm -t docker.pkg.github.com/explorviz/istio-playground/jvm:latest .
}

deploy() {
  kubectl create namespace quarkus &
  
  echo "Delete old version."
  kubectl delete -f <(istioctl kube-inject -f src/main/kube/app.yaml) -n quarkus

  echo "Deploy new version."
  kubectl apply -f <(istioctl kube-inject -f src/main/kube/app.yaml) -n quarkus

  INGRESS_HOST=$(minikube ip)
  INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
  echo "##########################################################################"
  echo "Application started: http://$INGRESS_HOST:$INGRESS_PORT/login.html"
  echo "##########################################################################"
}

$1
