# Kubernetes Cluster in my Home Network

## Installation

```sh
brew install hashicorp/tap/hashicorp-vagrant
brew install qemu
vagrant plugin install vagrant-qemu
vagrant up
```

## Topology

```plaintext
Router
 Host 1: MacOS (32GB/10CPU)
  Node: Control 1
  Node: Infra 1
  Node: Worker 1
  Node: Worker 2
  Node: Worker 3
 Host 2: Windows 10 (8GB/4CPU)
  Node: Control 2
  Node: Infra 2
  Node: Worker 4
 Host 3: Windows 11 (16GB/8CPU)
  Node: Control 3
  Node: Worker 5
  Node: Worker 6
```
