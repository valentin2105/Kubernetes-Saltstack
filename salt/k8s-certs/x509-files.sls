---
{%- import slspath + "/k8s_params.jinja" as params with context %}
/var/lib/kubernetes/ca.pem:
  file.managed:
    - source: {{ params.ca_certificates.path }}/{{ params.pki_ca }}.crt
    - group: root
    - mode: 644

/var/lib/kubernetes/kubernetes-key.pem:
  file.managed:
    - source: {{ params.pki_path }}/{{ params.pki_cert }}.key
    - group: root
    - mode: 600

/var/lib/kubernetes/kubernetes.pem:
  file.managed:
    - source: {{ params.pki_path }}/{{ params.pki_cert }}.crt
    - group: root
    - mode: 644

## Token & Auth Policy
/var/lib/kubernetes/token.csv:
  file.managed:
    - source:  salt://{{ slspath }}/token.csv
    - template: jinja
    - group: root
    - mode: 600
