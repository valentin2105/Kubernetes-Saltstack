/var/lib/kubernetes:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750

/etc/pki:
  file.directory: []

/etc/pki/issued_certs:
  file.directory: []    

/etc/pki/ca.key:                                                
  x509.private_key_managed:                                     
    - bits: 4096                                                
    - backup: True                                              
    - require:                                                  
      - file: /etc/pki                                          

/etc/pki/ca.crt:                                                
  x509.certificate_managed:                                     
    - signing_private_key: /etc/pki/ca.key                      
    - CN: ca.example.com                                        
    - C: US                                                     
    - ST: Utah                                                  
    - L: Salt Lake City                                         
    - basicConstraints: "critical CA:true"                      
    - keyUsage: "critical cRLSign, keyCertSign"                 
    - subjectKeyIdentifier: hash                                
    - authorityKeyIdentifier: keyid,issuer:always               
    - days_valid: 3650                                          
    - days_remaining: 0                                         
    - backup: True                                              
    - require:                                                  
      - file: /etc/pki                                          
      - x509: /etc/pki/ca.key    

mine.send:
  module.run:
    - func: x509.get_pem_entries
    - kwargs:
        glob_path: /etc/pki/ca.crt
    - onchanges:
      - x509: /etc/pki/ca.crt

/var/lib/kubernetes/ca.pem:
  file.managed:
    - source:  salt://certs/ca.pem
    - group: root
    - mode: 644

/var/lib/kubernetes/ca-key.pem:
  file.managed:
    - source:  salt://certs/ca-key.pem
    - group: root
    - mode: 600

/var/lib/kubernetes/kubernetes-key.pem:
  file.managed:
    - source:  salt://certs/kubernetes-key.pem
    - group: root
    - mode: 600

/var/lib/kubernetes/kubernetes.pem:
  file.managed:
    - source:  salt://certs/kubernetes.pem
    - group: root
    - mode: 644

## Token & Auth Policy
/var/lib/kubernetes/token.csv:
  file.managed:
    - source:  salt://certs/token.csv
    - template: jinja
    - group: root
    - mode: 600
