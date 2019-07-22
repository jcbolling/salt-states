{% from "mysql/map.jinja" import mysql with context %}

install_mariadb_repo:
  pkgrepo.managed:
    - name: MariaDB
    - baseurl: http://yum.mariadb.org/10.1/centos7-amd64
    - gpgcheck: 1
    - gpgkey: https://yum.mariadb.org/RPM-GPG-KEY-MariaDB

install_mysql_server:
  pkg.installed:
    - name: {{ mysql.server }}
    - require:
      - pkgrepo: MariaDB

ensure_mysql_server_is_running:
  service.running:
    - name: {{ mysql.service }}
    - enable: True
    - require:
      - pkg: {{ mysql.server }}