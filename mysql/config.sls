{% from "mysql/map.jinja" import mysql with context %}

mysql_server_configuration:
  file.managed:
    - name: {{ mysql.server_config }}
    - source: {{ mysql.server_config_source }}
    - template: jinja
    - require:
      - pkg: {{ mysql.server }}