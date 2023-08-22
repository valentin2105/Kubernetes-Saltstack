/var/lib/kubernetes:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750

/var/lib/kubernetes/ca.pem:
  file.managed:
    - source:  salt://{{ slspath }}/ca.pem
    - group: root
    - mode: 644

/var/lib/kubernetes/ca-key.pem:
  file.managed:
    - source:  salt://{{ slspath }}/ca-key.pem
    - group: root
    - mode: 600

/var/lib/kubernetes/kubernetes-key.pem:
  file.managed:
    - source:  salt://{{ slspath }}/kubernetes-key.pem
    - group: root
    - mode: 600

/var/lib/kubernetes/kubernetes.pem:
  file.managed:
    - source:  salt://{{ slspath }}/kubernetes.pem
    - group: root
    - mode: 644

## Token & Auth Policy
/var/lib/kubernetes/token.csv:
  file.managed:
    - source:  salt://{{ slspath }}/token.csv
    - template: jinja
    - group: root
    - mode: 600
