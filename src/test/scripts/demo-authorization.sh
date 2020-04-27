#!/bin/bash

set -e

WAIT_FOR_POLICY_IN_SECONDS=${2:-45}

CHECKMARK="\xE2\x9C\x94"
CROSS="\xE2\x9D\x8C"
echo "Applying authorization:"

sleep_with_progressbar() {
    printf "$1["
    printf ' %.0s' {1..50}
    printf "]\r$1["
    x=$(echo "scale=1 ; $2 / 50" | bc)
    for i in {1..50}; do
        printf "|"
        sleep $x
    done
    printf "]$CHECKMARK\n"
}

DENY_pattern() {
    echo "RBAC: access denied"
}

ALLOW_pattern() {
    echo "<title>Github auth example</title>"
}

checkAccessFromOtherNs() {
    printf "$1 to $2: $3 "
    pod=$(kubectl get pods -n foo -o jsonpath="{.items[*].metadata.name}" -l app=$1-app)
    if kubectl exec -n foo -it "$pod" -c istio-playground -- curl http://$2-app-service.quarkus:8000/login.html | grep -q "$($3_pattern)"; then
        printf "$CHECKMARK\n"
    else
        printf "$CROSS\n"
        exit 1
    fi
}

checkAccess() {
    printf "$1 to $2: $3 "
    pod=$(kubectl get pods -n quarkus -o jsonpath="{.items[*].metadata.name}" -l app=$1-app)
    if kubectl exec -n quarkus -it "$pod" -c istio-playground -- curl http://$2-app-service.quarkus:8000/login.html | grep -q "$($3_pattern)"; then
        printf "$CHECKMARK\n"
    else
        printf "$CROSS\n"
        exit 1
    fi
}

applyPolicy() {
    kubectl apply -f src/test/resources//kube/quarkus/authorization/${1}.yaml
    sleep_with_progressbar "Applying policy '$1' " $WAIT_FOR_POLICY_IN_SECONDS
}

cleanup() {
    echo "Cleaning up..."
    kubectl delete authorizationpolicies.security.istio.io -n quarkus --all
    echo "Cleaning finished."
}

trap "cleanup" EXIT

test_one_for_one() {
    echo "Confirm that all can be accessed:"
    checkAccess rest web "ALLOW"
    checkAccess web rest "ALLOW"
    checkAccessFromOtherNs other-ns rest "ALLOW"
    checkAccessFromOtherNs other-ns web "ALLOW"

    applyPolicy deny-all
    checkAccess rest web "DENY"
    checkAccess web rest "DENY"
    checkAccessFromOtherNs other-ns rest "DENY"
    checkAccessFromOtherNs other-ns web "DENY"

    applyPolicy allow-get-on-web-app
    checkAccess rest web "ALLOW"
    checkAccess web rest "DENY"
    checkAccessFromOtherNs other-ns rest "DENY"
    checkAccessFromOtherNs other-ns web "ALLOW"

    applyPolicy allow-get-from-web-app
    checkAccess rest web "ALLOW"
    checkAccess web rest "ALLOW"
    checkAccessFromOtherNs other-ns rest "DENY"
    checkAccessFromOtherNs other-ns web "ALLOW"
}

test_all_at_once() {
    for policy in src/test/resources/kube/quarkus/authorization/*; do
        kubectl apply -f ${policy}
    done
    sleep_with_progressbar "Waiting for policies to be enabled " $WAIT_FOR_POLICY_IN_SECONDS

    checkAccess rest web "ALLOW"
    checkAccess web rest "ALLOW"
    checkAccessFromOtherNs other-ns rest "DENY"
    checkAccessFromOtherNs other-ns web "ALLOW"
}

$1

echo "Finished without errors"