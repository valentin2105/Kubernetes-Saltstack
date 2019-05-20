{%- set cniVersion = pillar['kubernetes']['worker']['networking']['cni-version'] -%}
{%- set cniProvider = pillar['kubernetes']['worker']['networking']['provider'] -%}

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
    - source: 
{%- if "v0.7" in cniVersion %}
      - https://github.com/containernetworking/plugins/releases/download/{{ cniVersion }}/cni-plugins-amd64-{{ cniVersion }}.tgz
{% else %}
      - https://github.com/containernetworking/plugins/releases/download/{{ cniVersion }}/cni-plugins-linux-amd64-{{ cniVersion }}.tgz
{%- endif %}
    - skip_verify: true
    - archive_format: tar
    - if_missing: /opt/cni/bin/loopback

include:
  - .{{ cniProvider }}
