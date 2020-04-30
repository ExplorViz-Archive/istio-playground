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
  kubectl delete -f src/test/resources/kube/quarkus/web-app/httpbin-app.yaml

  echo "Deploy new version."
  kubectl apply -f src/test/resources/kube/quarkus/web-app/other-ns-app.yaml
  kubectl apply -f src/test/resources/kube/quarkus/web-app/web-app.yaml
  kubectl apply -f src/test/resources/kube/quarkus/web-app/httpbin-app.yaml

  INGRESS_HOST=$(minikube ip)
  INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
  echo "##########################################################################"
  echo "Application started: http://$INGRESS_HOST:$INGRESS_PORT/login.html"
  echo "##########################################################################"
}

apply() {
  kubectl apply -n $1 -f src/test/resources/kube/$2
}

demo_simple_authentication() {
  kubectl create namespace quarkus &
  kubectl label namespace quarkus istio-injection=enabled
  apply quarkus quarkus/web-app/web-app.yaml #deploy the demo app
  apply quarkus quarkus/traffic-management/virtual-service.yaml #make the app accessible via service
  apply quarkus quarkus/traffic-management/gateway.yaml #setup a gateway
  apply quarkus quarkus/authentication/authentication-policy.yaml #require authentication for some resources
}

demo_authorization() {
  demo_simple_authentication
  kubectl create namespace foo &
  kubectl label namespace foo istio-injection=enabled
  # deploy more applications
  apply foo quarkus/web-app/web-app.yaml
  apply foo quarkus/web-app/httpbin.yaml
  apply quarkus quarkus/web-app/httpbin.yaml
  apply quarkus quarkus/web-app/web-app-other-versions.yaml
  apply quarkus quarkus/authorization/deny-all.yaml
  apply quarkus quarkus/authorization/allow-get-on-web-app.yaml
  apply quarkus quarkus/authorization/allow-get-from-web-app.yaml
}

$1
