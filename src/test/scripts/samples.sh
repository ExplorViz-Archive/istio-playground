#!/bin/bash

set -e

while getopts ":s" opt; do
  case ${opt} in
    s )
      sleep=true
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      ;;
  esac
done
shift $((OPTIND -1))

my_dir="$(dirname "$0")"
source $my_dir/helpers.sh
for f in $my_dir/$1/*.sh; do source $f; done

apply() {
  kubectl $MODE -n $1 -f src/test/resources/kube/$2
}

create_namespace() {
  kubectl create namespace $1 &
  kubectl label namespace $1 istio-injection=enabled &
}

### default deployments
default_setup() {
  create_namespace quarkus
  apply quarkus quarkus/web-app/web-app.yaml                    #deploy the demo app
  apply quarkus quarkus/traffic-management/virtual-service.yaml #make the app accessible via service
  apply quarkus quarkus/traffic-management/gateway.yaml         #setup a gateway
}

setup() {
  MODE=apply
  pods
  policies
  kubectl wait --for=condition=Ready pod --all-namespaces --timeout=60s --all
  if [ ! -z "$sleep" ]; then
    sleep_with_progressbar "Waiting for policies to be enabled " 45
  fi
}

verify() {
  echo "Verifying access..."
  do_verify
  echo "Verifyied access."
}

cleanup() {
  echo "Cleaning up..."
  MODE=delete
  pods
  policies
  echo "Cleaning finished."
}

$2
