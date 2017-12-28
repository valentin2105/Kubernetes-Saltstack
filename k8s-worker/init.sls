{%- set k8s-version = pillar['kubernetes']['version'] -%}
{%- set dockerVersion = pillar['k8s']['dockerVersion'] -%}
{%- set enableIPv6 = pillar['k8s']['enableIPv6'] -%}

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

{% if not salt['file.directory_exists' ]('/dockerFS') %}
/dockerFS:
  file.directory:
    - user:  root
    - group:  root
    - mode:  '755'
{% endif %}

docker-latest-archive:
  archive.extracted:
    - name: /opt/
    - source: https://download.docker.com/linux/static/stable/x86_64/docker-{{ dockerVersion }}.tgz
    - skip_verify: true
    - archive_format: tar
    - if_missing: /opt/docker/

/usr/bin/docker-containerd:
  file.symlink:
    - target: /opt/docker/docker-containerd

/usr/bin/docker-containerd-ctr:
  file.symlink:
    - target: /opt/docker/docker-containerd-ctr

/usr/bin/docker-containerd-shim:
  file.symlink:
    - target: /opt/docker/docker-containerd-shim

/usr/bin/dockerd:
  file.symlink:
    - target: /opt/docker/dockerd

/usr/bin/docker:
  file.symlink:
    - target: /opt/docker/docker

/usr/bin/docker-proxy:
  file.symlink:
    - target: /opt/docker/docker-proxy

/usr/bin/docker-runc:
  file.symlink:
    - target: /opt/docker/docker-runc

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

/etc/systemd/system/docker.service:
    file.managed:
    - source: salt://k8s-worker/docker.service
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

docker:
  service.running:
    - enable: True
    - watch:
      - /etc/systemd/system/docker.service

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

