{% from wordpress/map.jinja import wordpress with context %}

download_and_install_wpcli_tool:
  file.managed:
    - name: /usr/local/bin/wp
    - source: https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    - source_hash: ttps://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar.sha512
    - runas: {{ wordpress.user }}
    - user: {{ wordpress.user }}
    - group: {{ wordpress.group }}
    - mode: 740