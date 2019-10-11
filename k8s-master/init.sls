{%- set k8sVersion = pillar['kubernetes']['version'] -%}
{%- set masterCount = pillar['kubernetes']['master']['count'] -%}
{% set post_install_files = [
  "coredns.yaml", "grafana.yaml", "heapster-rbac.yaml", "heapster.yaml",
  "influxdb.yaml", "metallb-configmap.yaml", "policy-controller.yaml", "rbac-calico.yaml", "rbac-tiller.yaml", "setup.sh"] %}

# set empty if k8s-master is at the same level of top.sls
# set <path> if k8s-master is in a sub folder
{% set root_path = "" if ((slspath | wordcount) < 3) else slspath.split("/")[0] %}

include:
  - .etcd

/usr/bin/kube-apiserver:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ k8sVersion }}/bin/linux/amd64/kube-apiserver
    - skip_verify: true
    - group: root
    - mode: 755

/usr/bin/kube-controller-manager:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ k8sVersion }}/bin/linux/amd64/kube-controller-manager
    - skip_verify: true
    - group: root
    - mode: 755

/usr/bin/kube-scheduler:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ k8sVersion }}/bin/linux/amd64/kube-scheduler
    - skip_verify: true
    - group: root
    - mode: 755

/usr/bin/kubectl:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ k8sVersion }}/bin/linux/amd64/kubectl
    - skip_verify: true
    - group: root
    - mode: 755
{% if masterCount == 1 %}
/etc/systemd/system/kube-apiserver.service:
    file.managed:
    - source: salt://{{ slspath }}/kube-apiserver.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644
{% elif masterCount == 3 %}
/etc/systemd/system/kube-apiserver.service:
    file.managed:
    - source: salt://{{ slspath }}/kube-apiserver-ha.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644
{% endif %}

/etc/systemd/system/kube-controller-manager.service:
  file.managed:
    - source: salt://{{ slspath }}/kube-controller-manager.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/systemd/system/kube-scheduler.service:
  file.managed:
    - source: salt://{{ slspath }}/kube-scheduler.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/var/lib/kubernetes/encryption-config.yaml:
    file.managed:
    - source: salt://{{ slspath }}/encryption-config.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644

{%- set cniProvider = pillar['kubernetes']['worker']['networking']['provider'] -%}
{% if cniProvider == "calico" %}

/opt/calico.yaml:
    file.managed:
    - source: salt://{{ root_path }}/k8s-worker/cni/calico/calico.tmpl.yaml
    - user: root
    - template: jinja
    - group: root
    - mode: 644
{% endif %}

{% for file in post_install_files %}
/opt/kubernetes/post_install/{{ file }}:
  file.managed:
  - source: salt://{{ root_path }}/post_install/{{ file }}
  - makedirs: true
  - template: jinja
  - user: root
  - group: root
{% if file == "setup.sh" %}
  - mode: 755
{% else %}
  - mode: 644
{% endif %}
{% endfor %}

kube-apiserver:
  service.running:
    - enable: True
    - watch:
      - /etc/systemd/system/kube-apiserver.service
      - /var/lib/kubernetes/kubernetes.pem
      - /var/lib/kubernetes/ca.pem
kube-controller-manager:
  service.running:
    - enable: True
    - watch:
      - /etc/systemd/system/kube-controller-manager.service
      - /var/lib/kubernetes/kubernetes.pem
      - /var/lib/kubernetes/ca.pem
kube-scheduler:
  service.running:
    - enable: True
    - watch:
      - /etc/systemd/system/kube-scheduler.service
      - /var/lib/kubernetes/kubernetes.pem
      - /var/lib/kubernetes/ca.pem

{% set cniProvider = pillar['kubernetes']['worker']['networking']['provider'] %}
{% if cniProvider == "calico" %}
{% set calicoctlVersion = pillar['kubernetes']['worker']['networking']['calico']['calicoctl-version'] %}

/etc/calico:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750

/etc/calico/calicoctl.cfg:
  file.managed:
    - source: salt://k8s-worker/cni/calico/calicoctl.cfg
    - user: root
    - template: jinja
    - group: root
    - mode: 640

/usr/bin/calicoctl:
  file.managed:
    - source: https://github.com/projectcalico/calicoctl/releases/download/{{ calicoctlVersion }}/calicoctl
    - skip_verify: true
    - group: root
    - mode: 755

{% endif %}
