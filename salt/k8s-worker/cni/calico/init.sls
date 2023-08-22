{%- set calicoCniVersion = pillar['kubernetes']['worker']['networking']['calico']['cni-version'] -%}
{%- set calicoctlVersion = pillar['kubernetes']['worker']['networking']['calico']['calicoctl-version'] -%}

# set k8s-worker.cni if k8s-worker is at the same level of top.sls
# set <path>.k8s-worker.cni if k8s-worker is in a sub folder
{% set require_cni = "cni-latest-archive" %}

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

/etc/calico/kube/:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750

/opt/cni/bin/calico:
  file.managed:
    - source:
{%- if "v3.1" in calicoCniVersion or calicoCniVersion in ["v3.2.1","v3.2.2"] %}
      - https://github.com/projectcalico/cni-plugin/releases/download/{{ calicoCniVersion }}/calico
{% else %}
      - https://github.com/projectcalico/cni-plugin/releases/download/{{ calicoCniVersion }}/calico-amd64
{%- endif %}
    - skip_verify: true
    - group: root
    - mode: 755
    - require:
      - id: {{ require_cni }}

/opt/cni/bin/calico-ipam:
  file.managed:
    - source:
{%- if "v3.1" in calicoCniVersion or calicoCniVersion in ["v3.2.1","v3.2.2"] %}
      - https://github.com/projectcalico/cni-plugin/releases/download/{{ calicoCniVersion }}/calico-ipam
{% else %}
      - https://github.com/projectcalico/cni-plugin/releases/download/{{ calicoCniVersion }}/calico-ipam-amd64
{%- endif %}
    - skip_verify: true
    - group: root
    - mode: 755
    - require:
      - id: {{ require_cni }}

/etc/calico/kube/kubeconfig:
    file.managed:
    - source: salt://{{ slspath }}/kubeconfig
    - user: root
    - template: jinja
    - group: root
    - mode: 640
    - require:
      - id: {{ require_cni }}

/etc/calico/calicoctl.cfg:
    file.managed:
    - source: salt://{{ slspath }}/calicoctl.cfg
    - user: root
    - template: jinja
    - group: root
    - mode: 640
    - require:
      - id: {{ require_cni }}

/etc/cni/net.d/10-calico.conf:
    file.managed:
    - source: salt://{{ slspath }}/10-calico.conf
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - require:
      - id: {{ require_cni }}
