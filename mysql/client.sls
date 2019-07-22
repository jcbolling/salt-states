{% from "mysql/map.jinja" import mysql with context %}

install_mariadb_client:
  pkg.installed:
    - name: mariadb