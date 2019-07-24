{% from "wordpress/map.jinja" import wordpress with context %}
{% for site, arg in salt['pillar.get']('wordpress:sites', {}).items() %}

configure_wordpress_for_{{ site }}:
  cmd.run:
    - name: 'wp config create --dbhost={{ arg.database_host }} --dbname={{ arg.database_name }} --dbuser={{ arg.database_user }} --dbpass={{ arg.database_pass }} --path={{ wordpress.document_root }}'
    - runas: {{ wordpress.user }}
    - unless: test -f {{ wordpress.docroot }}/{{ arg.rootdir }}wp-config.php

{% endfor %}