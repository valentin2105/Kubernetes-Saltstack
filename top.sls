base:
  '*':
  {% if "k8s-master" in grains.get('role', []) %}
    - certs
    - etcd
    - k8s-master
  {% endif %}
  {% if "k8s-worker" in grains.get('role', []) %}
    - certs
    - cni
    - k8s-worker
  {% endif %}
