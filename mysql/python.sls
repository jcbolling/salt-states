{% from "mysql/map.jinja" import mysql with context %}

include:
  - mysql

install_mysql_python_package:
  pkg.installed:
    - name: {{ mysql.python_package }}