---
{%- import slspath + "/k8s_params.jinja" as params with context %}
k8s_ca_certs_dir:
  file.directory:
    - name: "{{ params.pki_path }}/issued_certs"
    - makedirs: True

k8s_ca_signing_key:
  x509.private_key_managed:
    - name: "{{ params.pki_path }}/{{ params.pki_ca }}.key"
    - bits: 4096
    - require:
      - file: k8s_ca_certs_dir

k8s_ca_root_cert:
  x509.certificate_managed:
    - name: "{{ params.pki_path }}/{{ params.pki_ca }}.crt"
    - signing_private_key: "{{ params.pki_path }}/{{ params.pki_ca }}.key"
    - CN: {{grains['id']}}
    - basicConstraints: "critical CA:true"
    - keyUsage: "critical cRLSign, keyCertSign"
    - subjectKeyIdentifier: hash
    - authorityKeyIdentifier: keyid,issuer:always
    - days_valid: 3650
    - days_remaining: 0
    - backup: True
    - require:
      - x509: k8s_ca_signing_key

mine.send:
  module.run:
    - func: x509.get_pem_entries
    - kwargs:
        glob_path: "{{ params.pki_path }}/{{ params.pki_ca }}.*"
    - onchanges:
      - x509: k8s_ca_root_cert

k8s_ca_signing_policies:
  file.managed:
    - name: /etc/salt/minion.d/signing_policies.conf
    - source: salt://{{ slspath }}/signing_policies.conf
    - template: jinja
    - context:
        pki_path: {{ params.pki_path }}
        pki_ca: {{ params.pki_ca }}
        wildcard: '{{ params.wildcard }}'
  service.running:
    - name: salt-minion
    - watch:
      - file: k8s_ca_signing_policies
