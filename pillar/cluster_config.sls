kubernetes:
  version: v1.8.6
  domain: cluster.local
  master:
    count: 1
    hostname: k8s-master.hostname.tld
    etcd:
      version: v3.2.12
  worker:
    runtime:
      provider: docker
      docker:
        version: 17.09.1-ce
        data-dir: /dockerFS
    networking:
      cni-version: v0.6.0
      provider: calico
      calico:
        version: v3.0.1
        cni-version: v2.0.0
        calicoctl-version: v2.0.0
        enable-ipv6: false
        ipv4-range: 192.168.0.0/16
        ipv6-range: fd80:24e2:f998:72d6::/64
        nat-ipv4: true
        nat-ipv6: true
        as-number: 64512
        ip-in-ip: true
        token: hu0daeHais3aCHANGEMEhu0daeHais3a
  global:
    clusterIP-range: 10.32.0.0/16
    helm-version: v2.7.2
    admin-token: Haim8kay1rarCHANGEMEHaim8kay1rar
    kubelet-token: ahT1eipae1wiCHANGEMEahT1eipae1wi  
