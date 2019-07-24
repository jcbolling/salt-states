install_apache:
  pkg.installed:
    - name: {{ apache.package }}