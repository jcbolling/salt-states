wordpress_mysql_user:
  mysql_user.present:
    - name: wordpress_user
    - password: {{ pillar['mysql']['wordpress_user']['password'] }}
    - host: {{ pillar['mysql']['server']['bind_address'] }}
    - connection_user: root
    - connection_pass: {{ pillar['mysql']['root']['password'] }}
    - connection_charset: utf8

wordpress_user_grants:
  mysql.grants_present:
    - database: wordpress.*
    - user: wordpress_user
    - grant: ALL PRIVILEGES
    - connection_user: root
    - connection_pass: {{ pillar['mysql']['root']['password'] }}
    - connection_charset: utf8