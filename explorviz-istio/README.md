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

# Install istio inside of the kind cluster
./istiow setup-istio

# Install explorviz via helm
./istiow install
```