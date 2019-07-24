{% from "wordpress/map.jinja" import wordpress with context %}

include:
  - wordpress.wpcli

document_root_permissions:
  file.directory:
    - name: {{ wordpress.document_root }}
    - runas: {{ wordpress.user }}
    - owner: {{ wordpress.user }}
    - group: {{ wordpress.group }}
    - mode: 755

download_wordpress:
  cmd.run:
    - name: 'wp core download --path="{{ wordpress.document_root }}"'
    - runas: {{ wordpress.user }}
    - unless: test -f {{ wordpress.document_root }}/wp-config.php