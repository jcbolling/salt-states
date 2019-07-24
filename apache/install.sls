{% from "apache/map.jinja" import wordpress with context %}

install_apache:
  pkg.installed:
    - name: {{ apache.package }}