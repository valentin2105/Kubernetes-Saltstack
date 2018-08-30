kubernetes:
  version: v1.11.2
  domain: cluster.local
  master:
#    count: 1
#    hostname: master.domain.tld
#    ipaddr: 10.240.0.10
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
    encryption-key: 'w3RNESCMG+o3GCHTUcrQUUdq6CFV72q/Zik9LAO8uEc='
    etcd:
      version: v3.3.9
  worker:
    runtime:
      provider: docker
      docker:
        version: 18.03.0-ce
        data-dir: /dockerFS
    networking:
      cni-version: v0.7.1
      provider: calico
      calico:
        version: v3.2.1
        cni-version: v3.2.1
        calicoctl-version: v3.2.1
        controller-version: 3.2-release
        as-number: 64512
        token: hu0daeHais3aCHANGEMEhu0daeHais3a
        ipv4:
          range: 192.168.0.0/16
          nat: true
          ip-in-ip: true
        ipv6:
          enable: false
          nat: true
          interface: eth0
          range: fd80:24e2:f998:72d6::/64
  global:
    clusterIP-range: 10.32.0.0/16
    helm-version: v2.10.0
    dashboard-version: v1.10.0
    admin-token: Haim8kay1rarCHANGEMEHaim8kay11ra
    kubelet-token: ahT1eipae1wiCHANGEMEahT1eipa1e1w
