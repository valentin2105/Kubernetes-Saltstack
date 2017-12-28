{%- set cni-version = pillar['kubernetes']['networking']['cni-version'] -%}
{%- set cni-provider = pillar['kubernetes']['networking']['provider'] -%}
include:
{%- if cni-provider == "calico" -%}
  - k8s-worker/cni/calico
{%- elif cni-provider == "flannel" -%}
  - k8s-worker/cni/flannel
{%- endif -%}

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
    - source: https://github.com/containernetworking/plugins/releases/download/{{ cni-version }}/cni-plugins-amd64-{{ cni-version }}.tgz
    - skip_verify: true
    - archive_format: tar
    - if_missing: /opt/cni/bin/loopback

