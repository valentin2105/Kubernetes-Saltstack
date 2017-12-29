{%- set cniVersion = pillar['kubernetes']['networking']['cni-version'] -%}
{%- set cniProvider = pillar['kubernetes']['networking']['provider'] -%}

include:
  - k8s-worker/cni/{{ cniProvider }}

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

cni-latest-archive:
  archive.extracted:
    - name: /opt/cni/bin
    - source: https://github.com/containernetworking/plugins/releases/download/{{ cniVersion }}/cni-plugins-amd64-{{ cniVersion }}.tgz
    - skip_verify: true
    - archive_format: tar
    - if_missing: /opt/cni/bin/loopback


