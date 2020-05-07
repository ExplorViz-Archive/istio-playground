#!/bin/bash

set -e

do_verify() {
    FORTIO_POD=$(kubectl get pod -n quarkus | grep fortio | awk '{ print $1 }')
    kubectl exec -it $FORTIO_POD -n quarkus -c fortio /usr/bin/fortio -- load -c 4 -qps 0 -n 200 -loglevel Warning http://web-app-service.quarkus.svc.cluster.local:8000/secret
}

