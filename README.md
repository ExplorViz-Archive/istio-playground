

# istio-playground project

This project uses Quarkus, the Supersonic Subatomic Java Framework.

If you want to learn more about Quarkus, please visit its website: https://quarkus.io/ .

## Running the application in dev mode

You can run your application in dev mode that enables live coding using:
```
./gradlew quarkusDev
```

## Setup Istio in a local minikube cluster

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
* start configuring minikube ingress
* build an image of the istio-playground application

To make the application accessible under `istio-playground.com` execute this script:
```
ingress_host=$(kubectl get ingress -n istio-system | awk 'FNR > 1 {print $4}')
if ! grep "$ingress_host" /etc/hosts; then echo -e "$ingress_host  istio-playground.com" | sudo tee -a /etc/hosts; fi
```

## Deploy a sample configuration
There are several istio-playground sample configurations.

### Authentication demo
To deploy the sample:
```
src/test/scripts/samples.sh authentication setup
```

To delete the sample:
```
src/test/scripts/samples.sh authentication cleanup
```

### Authorization demo
To deploy the sample:
```
src/test/scripts/samples.sh authorization setup
```

To delete the sample:
```
src/test/scripts/samples.sh authorization cleanup
```

## Update the application in a local minikube cluster
If you want to update the istio-playground image:
```
./gradlew playgroundDeploy
#mode=authorization
mode=authentication
src/test/scripts/samples.sh $mode cleanup
src/test/scripts/samples.sh $mode setup
```

# Explorviz in Kubernetes

The directory `explorviz-istio` contains everything needed to deploy explorviz in a minikube kubernetes.

To deploy it, follow these steps. [Helm](https://helm.sh/docs/intro/install/) has to be installed:
```
cd explorviz-istio
# setup minikube
./istiow minikube
# setup istio
./istiow istio
# deploy zookeeper, kafka and explorviz
./istiow deploy
# make it accessible under add-istio-playground-to-etc-hosts
./istiow add-istio-playground-to-etc-hosts

# A demo application can be found here
# https://github.com/ExplorViz/docs/wiki/Monitoring-Configuration
echo "Adjust the following properties:"
echo "kieker.monitoring.writer.tcp.SingleSocketTcpWriter.hostname=$(minikube ip)"
echo "kieker.monitoring.writer.tcp.SingleSocketTcpWriter.port=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="tcp")].nodePort}')"

# The kiali dashboard visualizes the delpoyed application:
istioctl dashboard kiali
```