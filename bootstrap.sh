#!/bin/bash
pushd "$(dirname "${BASH_SOURCE[0]}")/ansible" || exit
ansible-playbook create_cluster.yaml -K -i inventory.yaml "$@"
popd || exit
