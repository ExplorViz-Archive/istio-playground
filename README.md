

# istio-playground project

This project uses Quarkus, the Supersonic Subatomic Java Framework.

If you want to learn more about Quarkus, please visit its website: https://quarkus.io/ .

## Running the application in dev mode

You can run your application in dev mode that enables live coding using:
```
./gradlew quarkusDev
```

## Running the application in a local minikube cluster

Requirements:
* [minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/) installed
* [istioctl](https://istio.io/docs/setup/getting-started/#download) client in you PATH

To initialize the application run the following gradle command:
```
./gradlew playgroundInitialSetup
```

This will:
* start minikube with the required settings for istio.
  * If you already have minikube cluster started, you should delete it (or specify a profile).
* start istio with the default profile
* deploy istio-playground and configure istio to showcase its authentication and authorization capabilities
* print the url of the application

Since the external url supplied by minikube is not fixed, the login probably wont work. You will see an `Callback URL mismatch.` error.
To allow the callback URL it has to be configured here:
https://manage.auth0.com/#/applications/obzrLluUpRf2C1XsaEbGsPK1IXTf2Xwl/settings

To make the application accessible under `istio-playground.com` execute this script:
```
ingress_host=$(kubectl get ingress -n istio-system | awk 'FNR > 1 {print $4}')
if ! grep "$ingress_host" /etc/hosts; then echo -e "$ingress_host  istio-playground.com" | sudo tee -a /etc/hosts; fi
```


## Update the application in a local minikube cluster

If you want to update the application you can do so with
```
./gradlew playgroundDeploy
```

If you want to update the authentication policy found in src/main/kube/authentication-policy.yaml`
```
./gradlew playgroundSetupAuthenticationPolicy
```