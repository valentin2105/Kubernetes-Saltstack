{%- set k8sVersion = pillar['kubernetes']['version'] -%}

include:
  - k8s-master/etcd

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

/etc/systemd/system/kube-apiserver.service:
    file.managed:
    - source: salt://k8s-master/kube-apiserver.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/systemd/system/kube-controller-manager.service:
  file.managed:
    - source: salt://k8s-master/kube-controller-manager.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644

/etc/systemd/system/kube-scheduler.service:
  file.managed:
    - source: salt://k8s-master/kube-scheduler.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644

kube-apiserver:
  service.running:
    - enable: True
    - watch:
      - /etc/systemd/system/kube-apiserver.service
      - /var/lib/kubernetes/kubernetes.pem
kube-controller-manager:
  service.running:
    - enable: True
    - watch:
      - /etc/systemd/system/kube-controller-manager.service
      - /var/lib/kubernetes/kubernetes.pem
kube-scheduler:
  service.running:
   - enable: True
   - watch:
     - /etc/systemd/system/kube-scheduler.service
     - /var/lib/kubernetes/kubernetes.pem
