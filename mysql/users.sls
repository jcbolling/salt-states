wordpress_mysql_user:
  mysql_user.present:
    - name: wordpress_user
    - host: 10.242.228.26
    - connection_user: root
    - connection_pass:
    - connection_charset: utf8

wordpress_user_grants:
  mysql.grants_present:
    - database: wordpress.*
    - user: wpuser
    - grant: ALL PRIVILEGES
    - connection_user: root
    - connection_pass:
    - connection_charset: utf8