{%- set calicoCniVersion = pillar['k8s']['calicoCniVersion'] -%}
{%- set cniVersion = pillar['k8s']['cniVersion'] -%}
{%- set calicoctlVersion = pillar['k8s']['calicoctlVersion'] -%}

/usr/bin/calicoctl:
  file.managed:
    - source: https://github.com/projectcalico/calicoctl/releases/download/{{ calicoctlVersion }}/calicoctl
    - skip_verify: true
    - group: root
    - mode: 755

/etc/calico/:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750

/opt/calico/:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750

/opt/calico/bin:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750

/etc/cni:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750

/etc/cni/net.d:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750

/etc/cni/net.d/10-calico.conf:
    file.managed:
    - source: salt://cni/10-calico.conf
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/cni/net.d/calico-kubeconfig:
    file.managed:
    - source: salt://cni/calico-kubeconfig
    - user: root
    - template: jinja
    - group: root
    - mode: 644

cni-latest-archive:
  archive.extracted:
    - name: /opt/cni/bin
    - source: https://github.com/containernetworking/plugins/releases/download/{{ cniVersion }}/cni-plugins-amd64-{{ cniVersion }}.tgz
    - skip_verify: true
    - archive_format: tar
    - if_missing: /opt/cni/bin/loopback

/opt/cni/bin/calico:
  file.managed:
    - source: https://github.com/projectcalico/cni-plugin/releases/download/{{ calicoCniVersion }}/calico
    - skip_verify: true
    - group: root
    - mode: 755

/opt/cni/bin/calico-ipam:
  file.managed:
    - source: https://github.com/projectcalico/cni-plugin/releases/download/{{ calicoCniVersion }}/calico-ipam
    - skip_verify: true
    - group: root
    - mode: 755
