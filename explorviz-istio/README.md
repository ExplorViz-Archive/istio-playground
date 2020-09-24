# Explorviz in Kubernetes
## Requirements
### Install Istio
[istioctl](https://istio.io/docs/setup/getting-started/#download) client in you PATH

### Install Kind
[istio with kind](https://istio.io/latest/docs/setup/platform-setup/kind/)
[Install kind](https://kind.sigs.k8s.io/docs/user/quick-start/):

```
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.8.1/kind-$(uname)-amd64
chmod +x ./kind
mv ./kind /some-dir-in-your-PATH/kind
```

## Run explorviz in local kind cluster

```
# Move into this directory
cd explorviz-istio

# Create kind cluster
./istiow setup-kind

# Build Images with readiness probes
git clone -b explorviz-1.5-istio https://github.com/ExplorViz/explorviz-backend.git $HOME/explorviz-backend
cd explorviz-backend
./push-images-to-kind.sh
cd -

# Install istio inside of the kind cluster
./istiow setup-istio

# Install explorviz via helm
./istiow install
```

## GRPC Example

An example gRPC server is deployed alongside Explorviz. The following steps describe how to start a corresponding client.


### Initial setup
```
# Clone the grpc-java example git repository
git clone -b v1.32.1 https://github.com/grpc/grpc-java.git $HOME/grpc-java

# Compile and install the sources
cd $HOME/grpc-java/examples
./gradlew installDist
cd -
```

### Run client
Be sure to set the needed environment Variables
```
$HOME/grpc-java/examples/build/install/examples/bin/hello-world-client SomeUsername $EXPLORVIZ_URL:$GRPC_PORT
```