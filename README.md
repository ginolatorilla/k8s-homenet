# Kubernetes Cluster in my Home Network

My cluster configuration for a multi-node Kubernetes cluster spread across multiple physical computers is here.
I followed the instructions from the [official documentation of Kubernetes](https://kubernetes.io/docs/setup/production-environment/) as I built the cluster.

## Specifications

| Item                         | Value   |
| ---------------------------- | ------- |
| Hypervisor                   | LXD     |
| Hypervisor version           | 0.20.0  |
| Guest OS                     | Ubuntu  |
| Guest OS version             | 22.04   |
| Guest CPU architecture       | aarch64 |
| Kubernetes version           | 1.29.0  |
| Container runtime            | CRIO    |
| Container runtime version    | 1.29    |
| Container networking         | Calico  |
| Container networking version | 3.27.0  |
| Ingress controller           | Nginx   |
| Ingress controller version   | 3.4.3   |

![Network diagram](./docs/k8s-homenet-overview.png)

## Requirements

- Python 3
- Kubernetes CLI (`kubectl`)
- Helm
- Physical hosts
  - SSH server
  - Disable automatic suspend or shutdown (e.g. for laptops, when the lid is closed).
  - Disable swap
- Home router DHCP should exclude the virtual IPs for the Kubernetes API server and ingress.

## Installation

1. Change the variables in the inventory file at [ansible/inventory.yaml](./ansible/inventory.yaml).
2. Run `./bootstrap.sh`.
