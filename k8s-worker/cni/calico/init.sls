{%- set calicoCniVersion = pillar['kubernetes']['worker']['networking']['calico']['cni-version'] -%}
{%- set calicoctlVersion = pillar['kubernetes']['worker']['networking']['calico']['calicoctl-version'] -%}

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
{%- if "v3.1" in calicoCniVersion %}
      - https://github.com/projectcalico/cni-plugin/releases/download/{{ calicoCniVersion }}/calico
{% else %}
      - https://github.com/projectcalico/cni-plugin/releases/download/{{ calicoCniVersion }}/calico-amd64
{%- endif %}
    - skip_verify: true
    - group: root
    - mode: 755
    - require:
      - sls: {{ sls.split('.')[0] }}.k8s-worker.cni

/opt/cni/bin/calico-ipam:
  file.managed:
    - source: 
{%- if "v3.1" in calicoCniVersion %}
      - https://github.com/projectcalico/cni-plugin/releases/download/{{ calicoCniVersion }}/calico-ipam
{% else %}
      - https://github.com/projectcalico/cni-plugin/releases/download/{{ calicoCniVersion }}/calico-ipam-amd64
{%- endif %}
    - skip_verify: true
    - group: root
    - mode: 755
    - require:
      - sls: {{ sls.split('.')[0] }}.k8s-worker.cni

/etc/calico/kube/kubeconfig:
    file.managed:
    - source: salt://{{ slspath }}/kubeconfig
    - user: root
    - template: jinja
    - group: root
    - mode: 640
    - require:
      - sls: {{ sls.split('.')[0] }}.k8s-worker.cni

/etc/cni/net.d/10-calico.conf:
    file.managed:
    - source: salt://{{ slspath }}/10-calico.conf
    - user: root
    - template: jinja
    - group: root
    - mode: 644
    - require:
      - sls: {{ sls.split('.')[0] }}.k8s-worker.cni

