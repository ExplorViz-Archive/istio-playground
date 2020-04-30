#!/bin/bash

do_verify() {
    GATEWAY_URL=${GATEWAY_URL:-istio-playground.com}
    curl -s http://${GATEWAY_URL}/login.html | grep "Login page"
    curl -s http://${GATEWAY_URL}/asecret.html | grep "RBAC: access denied"
}
