{% from "wordpress/map.jinja" import wordpress with context %}
{% for site, arg in salt['pillar.get']('wordpress:sites', {}).items() %}

install_wordpress_for_{{ site }}:
  cmd.run:
    - name: 'wp core install --url="{{ arg.url }}" --title="{{ arg.title }}" --admin_user="{{ arg.adminuser }}" --admin_password="{{ arg.adminpass }}" --admin_email="{{ arg.admin_email }}" --path="{{ wordpress.document_root }}"'
    - runas: {{ wordpress.user }}
    - unless: wp core is-installed --path={{ wordpress.document_root}}/{{ arg.rootdir }}

{% endfor %}