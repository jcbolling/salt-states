{% from "apache/map.jinja" import apache with context %}

install_apache:
  pkg.installed:
    - name: {{ apache.package }}