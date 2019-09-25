---
{%- import slspath + "/k8s_params.jinja" as params with context %}
/var/lib/kubernetes:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750

k8s_salt_x509_module:
  pkg.installed:
    - name: m2crypto
    - reload_modules: True
  file.directory:
    - name: {{ params.pki_path }}
    - makedirs: True
    - mode: 0700
