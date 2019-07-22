wordpress_db:
  mysql_database.present:
    - name: wordpress
    - host: 10.242.228.26
    - connection_user: root
    - connection_pass:
    - connection_charset: utf8