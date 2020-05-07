#!/bin/bash

# used in helper.sh
pods() {
  default_setup
  # deploy more applications
  create_namespace foo
  apply foo     quarkus/web-app/web-app.yaml
  apply foo     quarkus/web-app/httpbin.yaml
  apply quarkus quarkus/web-app/httpbin.yaml
}

policies() {
  apply quarkus quarkus/authorization/deny-all.yaml
  apply quarkus quarkus/authorization/allow-get-on-web-app.yaml
  apply quarkus quarkus/authorization/allow-get-from-web-app.yaml
}
