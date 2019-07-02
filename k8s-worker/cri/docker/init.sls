{%- set dockerVersion = pillar['kubernetes']['worker']['runtime']['docker']['version'] -%}
{%- set dockerdata = pillar['kubernetes']['worker']['runtime']['docker']['data-dir'] -%}

{{ dockerdata }}:
  file.directory:
    - user:  root
    - group:  root
    - mode:  '711'

docker-latest-archive:
  archive.extracted:
    - name: /opt/
    - source: https://download.docker.com/linux/static/stable/x86_64/docker-{{ dockerVersion }}.tgz
    - skip_verify: true
    - archive_format: tar
    - if_missing: /opt/docker/

/usr/bin/containerd:
  file.symlink:
    - target: /opt/docker/containerd

/usr/bin/ctr:
  file.symlink:
    - target: /opt/docker/ctr

/usr/bin/containerd-shim:
  file.symlink:
    - target: /opt/docker/containerd-shim

/usr/bin/dockerd:
  file.symlink:
    - target: /opt/docker/dockerd

/usr/bin/docker-init:
  file.symlink:
    - target: /usr/bin/docker-init

/usr/bin/docker:
  file.symlink:
    - target: /opt/docker/docker

/usr/bin/docker-proxy:
  file.symlink:
    - target: /opt/docker/docker-proxy

/usr/bin/runc:
  file.symlink:
    - target: /opt/docker/runc

/etc/systemd/system/docker.service:
  file.managed:
    - source: salt://{{ slspath }}/docker.service
    - user: root
    - template: jinja
    - group: root
    - mode: 644

docker:
  service.running:
    - enable: True
    - watch:
      - /etc/systemd/system/docker.service
