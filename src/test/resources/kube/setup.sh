#!/bin/bash

# kubectl create ns quarkus
eval $(minikube docker-env)
docker build -f src/main/docker/Dockerfile.jvm -t istio/quarkus-oauth .
kubectl apply -f <(istioctl kube-inject -f src/main/kube/app.yaml) -n quarkus

echo "Starting"
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: quarkus-gateway
  namespace: quarkus
spec:
  selector:
    istio: ingressgateway # use Istio default gateway implementation
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"
EOF

kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: quarkus
  namespace: quarkus
spec:
  hosts:
  - "*"
  gateways:
  - quarkus-gateway
  http:
  - route:
    - destination:
        port:
          number: 8000
        host: quarkus-test.quarkus.svc.cluster.local
EOF

kubectl apply -f - <<EOF
apiVersion: "security.istio.io/v1beta1"
kind: "AuthorizationPolicy"
metadata:
  name: "frontend-ingress"
  namespace: istio-system
spec:
  selector:
    matchLabels:
      istio: ingressgateway
  action: DENY
  rules:
  - from:
    - source:
        notRequestPrincipals: ["*"]
    to:
    - operation:
        paths: ["/secret", "asecret.html", "asecret"]
EOF

INGRESS_HOST=$(minikube ip)
INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export INGRESS_URL="$INGRESS_HOST:$INGRESS_PORT"
echo $INGRESS_URL
