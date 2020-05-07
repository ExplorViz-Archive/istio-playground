#!/bin/bash

# used in helper.sh
pods() {
  default_setup
  # deploy more applications
  create_namespace foo
  apply foo     quarkus/web-app/web-app.yaml
  apply foo     quarkus/web-app/httpbin.yaml
  apply quarkus quarkus/web-app/httpbin.yaml
  apply quarkus quarkus/web-app/web-app-other-versions.yaml
  apply quarkus quarkus/traffic-management/fortio-deploy.yaml
}

policies() {
  apply quarkus quarkus/traffic-management/circuit-breaker.yaml
}
