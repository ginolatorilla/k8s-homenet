require 'socket'
require_relative 'node-base.rb'

def k8s_node(config, vmhost:, name:, type: "control-leader", size: :medium)
    return if Socket.gethostname != vmhost

    config.vm.define name do |node|
        base(config, vmhost)
        node.vm.hostname = name

        if ["control-leader", "control"].include? type
            size = :small
        end 

        node.vm.provider :vmware_desktop do |v|
            v.vmx["numvcpus"] = NODE_SIZE[size][:cpu]
            v.vmx["memsize"] = NODE_SIZE[size][:mem]
        end

        node.vm.provision "install", type: "shell", inline: <<~SCRIPT
            export DEBIAN_FRONTEND=noninteractive

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

        node.vm.provision "reload", type: "shell", run: "never",
            inline: <<~BASE << {"control-leader" => <<~CONTROL_LEADER, "control" => <<~CONTROL, "worker" => <<~WORKER }[type]
            systemctl restart systemd-resolved

            kubeadm reset -f
            rm -rf /etc/kubernetes/pki

            # Install Kubernetes
            kubeadm config images pull
        BASE
            mkdir -p /etc/kubernetes/pki/etcd
            cp /vagrant/etc/kubernetes/pki/ca.{key,crt} /etc/kubernetes/pki
            cp /vagrant/etc/kubernetes/pki/front-proxy-ca.{key,crt} /etc/kubernetes/pki
            cp /vagrant/etc/kubernetes/pki/etcd/ca.{key,crt} /etc/kubernetes/pki/etcd

            kubeadm init --pod-network-cidr=#{POD_CIDR} --control-plane-endpoint=#{CLUSTER_ENDPOINT}
            kubeadm token create --ttl 2h --print-join-command > /vagrant/var/kubeadm-join
            cp /etc/kubernetes/admin.conf /vagrant/var/admin.kubeconfig
            cp /etc/kubernetes/pki/sa.{key,pub} /vagrant/etc/kubernetes/pki

            # Install CNI
            export KUBECONFIG=/etc/kubernetes/admin.conf
            curl -fsSL https://docs.projectcalico.org/manifests/calico.yaml | kubectl apply -f-
        CONTROL_LEADER
            mkdir -p /etc/kubernetes/pki/etcd
            cp /vagrant/etc/kubernetes/pki/ca.{key,crt} /etc/kubernetes/pki
            cp /vagrant/etc/kubernetes/pki/front-proxy-ca.{key,crt} /etc/kubernetes/pki
            cp /vagrant/etc/kubernetes/pki/etcd/ca.{key,crt} /etc/kubernetes/pki/etcd

            cp /vagrant/etc/kubernetes/pki/sa.{key,pub} /etc/kubernetes/pki
            $(cat /vagrant/var/kubeadm-join) --control-plane
        CONTROL
            mkdir -p /etc/kubernetes/pki/etcd
            cp /vagrant/etc/kubernetes/pki/sa.{key,pub} /etc/kubernetes/pki
            $(cat /vagrant/var/kubeadm-join)
        WORKER

    end
end

