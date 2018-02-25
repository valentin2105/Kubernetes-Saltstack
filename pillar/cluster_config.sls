kubernetes:
  version: v1.9.3
  domain: cluster.local
  master:
    count: 3
    cluster:
      node01:
        hostname: master01.domain.tld
        ipaddr: 10.240.0.10
      node02:
        hostname: master02.domain.tld
        ipaddr: 10.240.0.20
      node03:
        hostname: master03.domain.tld
        ipaddr: 10.240.0.30
    etcd:
      version: v3.3.1
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
        version: v3.0.3
        cni-version: v2.0.2
        calicoctl-version: v2.0.0
        controller-version: v2.0.0
        as-number: 64512
        token: hu0daeHais3aCHANGEMEhu0daeHais3a
        ipv4:
          range: 192.168.0.0/16
          nat: true
          ip-in-ip: true
        ipv6:
          enable: false
          nat: true
          range: fd80:24e2:f998:72d6::/64
  global:
    clusterIP-range: 10.32.0.0/16
    helm-version: v2.8.0
    admin-token: Haim8kay1rarCHANGEMEHaim8kay1rar
    kubelet-token: ahT1eipae1wiCHANGEMEahT1eipae1wi  
