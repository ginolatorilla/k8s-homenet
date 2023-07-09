require 'socket'
require_relative 'node-base.rb'

def master(config, vmhost:, name:)
    return if Socket.gethostname != vmhost

    base(config, vmhost)

    config.vm.define name do |node|
        node.vm.hostname = name

        node.vm.provider :vmware_desktop do |v|
            v.vmx["numvcpus"] = "2"
            v.vmx["memsize"] = "2048"
        end

        node.vm.provision "install", type: "shell", inline: <<-SCRIPT
            /vagrant/scripts/install-base.sh

            # Install Kubernetes CLI tools
            apt-get install -y apt-transport-https ca-certificates curl
            curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --no-tty --dearmor -o /etc/apt/trusted.gpg.d/k8s.gpg
            curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
            echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
            apt-get update
            apt-get install -y kubelet kubeadm kubectl
            apt-mark hold kubelet kubeadm kubectl

            # Required for CNI
            echo overlay >> /etc/modules-load.d/k8s.conf
            echo br_netfilter >> /etc/modules-load.d/k8s.conf
            modprobe overlay
            modprobe br_netfilter

            # Ensure sysctl params are set
            echo 'net.bridge.bridge-nf-call-ip6tables = 1' >> /etc/sysctl.d/kubernetes.conf
            echo 'net.bridge.bridge-nf-call-iptables = 1' >> /etc/sysctl.d/kubernetes.conf
            echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.d/kubernetes.conf

            # Reload configs
            sysctl --system

            # Install CRI
            mkdir -p /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --no-tty  --dearmor -o /etc/apt/keyrings/docker.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
                $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            apt-get update
            apt-get install -y containerd.io
            containerd config default | sed 's/SystemdCgroup = false/SystemdCgroup = true/' > /etc/containerd/config.toml
            systemctl daemon-reload
            systemctl restart containerd
            systemctl enable containerd
        SCRIPT

        node.vm.provision "reload", after: "configure", type: "shell", inline: <<-SCRIPT
            systemctl restart systemd-resolved
            kubeadm reset -f
            mkdir -p /etc/kubernetes/pki/etcd
            cp /vagrant/etc/kubernetes/pki/*.{key,crt} /etc/kubernetes/pki
            cp /vagrant/etc/kubernetes/pki/etcd/*.{key,crt} /etc/kubernetes/pki/etcd

            # Install Kubernetes
            kubeadm config images pull
            kubeadm init --pod-network-cidr=#{POD_CIDR} --control-plane-endpoint=#{CLUSTER_ENDPOINT}

            # Install CNI
            export KUBECONFIG=/etc/kubernetes/admin.conf
            curl -fsSL https://docs.projectcalico.org/manifests/calico.yaml | kubectl apply -f-
        SCRIPT
    end
end

