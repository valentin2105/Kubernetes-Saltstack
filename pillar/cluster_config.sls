kubernetes:
  version: v1.16.1
  domain: cluster.local

  master:
    count: 1
    hostname: master.domain.tld
    ipaddr: 10.240.0.10

#    count: 3
#    cluster:
#      node01:
#        hostname: master01.domain.tld
#        ipaddr: 10.240.0.10
#      node02:
#        hostname: master02.domain.tld
#        ipaddr: 10.240.0.20
#      node03:
#        hostname: master03.domain.tld
#        ipaddr: 10.240.0.30

    etcd:
      version: v3.3.12
    encryption-key: '0Wh+uekJUj3SzaKt+BcHUEJX/9Vo2PLGiCoIsND9GyY='

  pki:
    enable: false
    host: master01.domain.tld
    wildcard: '*.domain.tld'

  worker:
    runtime:
      provider: docker
      docker:
        version: 18.09.9
        data-dir: /dockerFS
    networking:
      cni-version: v0.7.1
      provider: calico
      calico:
        version: v3.9.0
        cni-version: v3.9.0
        calicoctl-version: v3.9.0
        controller-version: 3.9-release
        as-number: 64512
        token: hu0daeHais3a--CHANGEME--hu0daeHais3a
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
    helm-version: v2.13.1
    dashboard-version: v2.0.0-beta4
    coredns-version: 1.6.4 
    admin-token: Haim8kay1rar--CHANGEME--Haim8kay11ra
    kubelet-token: ahT1eipae1wi--CHANGEME--ahT1eipa1e1w
    metallb: 
      enable: false
      version: v0.8.1
      protocol: layer2
      addresses: 10.100.0.0/24
    nginx-ingress:
      enable: false 
      version: 0.26.1
      service-type: LoadBalancer
    cert-manager:
      enable: false
      version: v0.11.0