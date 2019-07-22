{% from "mysql/map.jinja" import mysql with context %}

include:
  - mysql

install_mysql_python_package:
  - name: {{ mysql.python_package }}