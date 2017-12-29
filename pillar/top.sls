base:
  '*':
  {% if "k8s-master" in grains.get('role', []) or "k8s-worker" in grains.get('role', []) %}
    - cluster_config
  {% endif %}
