---
{%- from slspath + "/k8s_params.jinja" import ca_host with context %}
include:
{%- if salt["pillar.get"]("kubernetes:pki:enable") %}
  - .x509-base
{%-   if ca_host == salt["grains.get"]("fqdn") %}
  - .x509-ca
{%-   endif %}
{%-   if salt["mine.get"](ca_host, "x509.get_pem_entries")  or ca_host == salt["grains.get"]("fqdn") %}
  - .x509-req
  - .x509-files 
{%-   endif %}
{%  else %}
  - .files 
{%- endif %}
