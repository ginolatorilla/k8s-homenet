HOSTS = {
    "GPH00093m" => { os: "mac", arch: "arm64"  },
    "amihan" =>    { os: "win", arch: "x86_64" }
}

NODE_SIZE = {
    small: { cpu: "2", mem: "2048" },
    medium: { cpu: "2", mem: "4096" },
    large: { cpu: 2, mem: "8192" },
    xlarge: { cpu: 4, mem: "8192" }
}

POD_CIDR = "172.18.0.0/16"
CLUSTER_ENDPOINT = "api.k8s.homenet"