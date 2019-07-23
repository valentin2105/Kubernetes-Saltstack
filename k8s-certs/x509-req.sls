---
{%- import slspath + "/k8s_params.jinja" as params with context %}
k8s_internal_ca:
{%- if params.ca_host == salt["grains.get"]("fqdn") %}
  file.managed:
    - name: "{{ params.ca_certificates.path }}/{{ params.pki_ca }}.crt"
    - source: "{{ params.pki_path }}/{{ params.pki_ca }}.crt"
    - makedirs: True
{% else %}
  file.directory:
    - name: "{{ params.ca_certificates.path }}"
  x509.pem_managed:
    - name: "{{ params.ca_certificates.path }}/{{ params.pki_ca }}.crt"
    - text: {{ salt["mine.get"](params.ca_host, "x509.get_pem_entries") | traverse(params.ca_host + ":" + params.pki_path + "/" + params.pki_ca + ".crt") | replace("\n", "") }}
{%- endif %}
  cmd.run:
    - name: {{ params.ca_certificates.command }}
    - onchanges:
{%- if params.ca_host == salt["grains.get"]("fqdn") %}
      - file: k8s_internal_ca
{% else %}
      - x509: k8s_internal_ca
{%- endif %}

k8s_internal_ca_key:
{%- if params.ca_host == salt["grains.get"]("fqdn") %}
  file.managed:
    - name: "/var/lib/kubernetes/ca-key.pem"
    - source: "{{ params.pki_path }}/{{ params.pki_ca }}.key"
{% else %}
  x509.pem_managed:
    - name: "/var/lib/kubernetes/ca-key.pem"
    - text: {{ salt["mine.get"](params.ca_host, "x509.get_pem_entries") | traverse(params.ca_host + ":" + params.pki_path + "/" + params.pki_ca + ".key") | replace("\n", "") }}
    - makedirs: True
{%- endif %}

k8s_key:
  x509.private_key_managed:
    - name: "{{ params.pki_path }}/{{ params.pki_cert }}.key"
    - bits: 4096
 
{%- set ip_list = [] %}
{%- do ip_list.append("IP:" + ((salt["pillar.get"]("kubernetes:global:clusterIP-range","10.32.0.0/16").split("/")[0] + "/30") | ipaddr | network_hosts)[0]) %}
{%- for ip in salt['grains.get']('ipv4') %}
{%- do ip_list.append("IP:" + ip) %}
{%- endfor %}

k8s_cert:
  x509.certificate_managed:
    - name: "{{ params.pki_path }}/{{ params.pki_cert }}.crt"
    - ca_server: {{ params.ca_host }}
    - signing_policy: internal
    - public_key: "{{ params.pki_path }}/{{ params.pki_cert }}.key"
    - CN: {{ salt['grains.get']('fqdn') }}
    - subjectAltName: 'DNS:{{ salt["grains.get"]("fqdn") }}, {{ ip_list | join(", ") }}'
    - days_valid: 365
    - days_remaining: 10
