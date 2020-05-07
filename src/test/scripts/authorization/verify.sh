#!/bin/bash

set -e

checkAccess() {
    printf "$1 to $2: $4 "
    namespace=$(cut -d "." -f2 <<< "$1")
    pod=$(kubectl get pods -n $namespace -o jsonpath="{.items[*].metadata.name}" -l curl=able)
    http_code=$(kubectl exec -n $namespace "$pod" -c istio-playground -- curl -s -o /dev/null -w "%{http_code}" http://$2:8000/$3)
    if [ $4 = $http_code ]; then
        printf "$CHECKMARK\n"
    else
        printf "$CROSS --> $http_code\n "
        exit 1
    fi
}

applyPolicy() {
    kubectl apply -n quarkus -f src/test/resources//kube/quarkus/authorization/${1}.yaml
    sleep_with_progressbar "Applying policy '$1' " $WAIT_FOR_POLICY_IN_SECONDS
}

test_one_for_one() {
    echo "Confirm that all can be accessed:"
    checkAccess web.quarkus httpbin.quarkus         ip         200
    checkAccess web.foo     httpbin.quarkus         ip         200
    checkAccess web.foo     web-app-service.quarkus login.html 200

    applyPolicy deny-all
    checkAccess web.quarkus httpbin.quarkus         ip         403
    checkAccess web.foo     httpbin.quarkus         ip         403
    checkAccess web.foo     web-app-service.quarkus login.html 403

    applyPolicy allow-get-on-web-app
    checkAccess web.quarkus httpbin.quarkus         ip         403
    checkAccess web.foo     httpbin.quarkus         ip         403
    checkAccess web.foo     web-app-service.quarkus login.html 200

    applyPolicy allow-get-from-web-app
    checkAccess web.quarkus httpbin.quarkus         ip         200
    checkAccess web.foo     httpbin.quarkus         ip         403
    checkAccess web.foo     web-app-service.quarkus login.html 200
}

do_verify() {
    # for policy in src/test/resources/kube/quarkus/authorization/*; do
    #     kubectl apply -f ${policy}
    # done
    # sleep_with_progressbar "Waiting for policies to be enabled " 45
    #           FROM        TO                      PATH       HTTP_CODE
    checkAccess web.quarkus httpbin.quarkus         ip         200
    checkAccess web.foo     httpbin.quarkus         ip         403
    checkAccess web.foo     web-app-service.quarkus login.html 200
}

# kubectl exec -it $FORTIO_POD  -c fortio /usr/bin/fortio -- load -c 10 -qps 0 -n 200 -loglevel Warning http://web-app-service.quarkus.svc.cluster.local:8000/secret
