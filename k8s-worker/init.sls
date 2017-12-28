{%- set k8s-version = pillar['kubernetes']['version'] -%}
{%- set enableIPv6 = pillar['k8s']['enableIPv6'] -%}
include:
{% if "docker" in pillar['kubernetes']['worker']['runtime']['provider'] %}
  - k8s-worker/docker
{% elif "cri-containerd" in pillar['kubernetes']['worker']['runtime']['provider'] %}
  - k8s-worker/cri-containerd
{% endif %}

glusterfs-client:
  pkg.latest

conntrack:
  pkg.latest

nfs-common:
  pkg.latest

socat:
  pkg.latest


vm.max_map_count:
  sysctl.present:
    - value: 2097152

/usr/bin/kubelet:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ k8s-version }}/bin/linux/amd64/kubelet
    - skip_verify: true
    - group: root
    - mode: 755

/usr/bin/kube-proxy:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ k8s-version }}/bin/linux/amd64/kube-proxy
    - skip_verify: true
    - group: root
    - mode: 755

/var/lib/kubelet:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 700

/var/lib/kubelet/kubeconfig:
    file.managed:
    - source: salt://k8s-worker/kubeconfig
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/systemd/system/kubelet.service:
    file.managed:
    - source: salt://k8s-worker/kubelet.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/systemd/system/kube-proxy.service:
  file.managed:
    - source: salt://k8s-worker/kube-proxy.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/systemd/system/calico.service:
    file.managed:
    - source: salt://k8s-worker/calico.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kubelet:
  service.running:
    - enable: True
    - watch:
      - /etc/systemd/system/kubelet.service

kube-proxy:
  service.running:
    - enable: True
    - watch:
      - /etc/systemd/system/kube-proxy.service

calico:
  service.running:
   - enable: True
   - watch:
     - /etc/systemd/system/calico.service

{% if enableIPv6 == true %}
net.ipv6.conf.all.forwarding:
  sysctl.present:
    - value: 1
{% endif %}

