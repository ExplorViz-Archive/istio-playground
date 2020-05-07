#!/bin/bash

# used in samples.sh
pods() {
  default_setup
}

policies() {
  apply istio-system quarkus/authentication/authentication-policy.yaml #require authentication for some resources
}
