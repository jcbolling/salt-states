#######################################################################################
#                                                                                     #
# Author: Josh Bolling (http://joshbolling.com)                                       #
#                                                                                     #
# Date: 8/22/2016                                                                     #
#                                                                                     #
# State name: web-server-ec2                                                          #
#                                                                                     #
# Version: 1.0                                                                        #
#                                                                                     #
# Description: This state installs all necessary software packages to support         #
# Wordpress running on a standard LAMP stack. This state also mounts an EFS           #
# volume using the correct DNS address (determined by the AZ a given instance         #
# is running in) and symlinks /var/www/html to the EFS mount to avoid extensive       #
# changes to the /etc/httpd/conf/httpd.conf file.                                     #
#                                                                                     #
#######################################################################################


# Install Apache web server

install_httpd:
  pkg.installed:
    - name: httpd

# install PHP package

install php:
  pkg.installed:
    - name: php

# Install php-gd package

install php-gd:
  pkg.installed:
    - name: php-gd

# Install PHP MySQL extension

install_php_mysql_estension:
  pkg.installed:
    - name: php-mysql

# Install MySQL client. The MySQL client will only be used in the event of deployment in a new region requiring creation of databases.

install_mysql_client:
  pkg.installed:
    - name: mysql

# Install MySQL-pyhon package (pre-requsite package required by MySQL Salt module)

install_MySQL-python:
  pkg.installed:
    - name: MySQL-python26

# install nfs-utils package (pre-requsite package required to mount EFS volume)

install_nfs_utils:
  pkg.installed:
    - name: nfs-utils

# Mount EFS filesystem containing Wordpress files

# The following Jinja blocks determine the AZ a given instnace is running in and mounts the EFS volume using the correct
# DNS address.

/mnt/efs/web:
  mount.mounted:
    {% if salt['grains.get']('ec2:placement:availability_zone') == 'us-east-1a' %}
    - device: 'us-east-1a.fs-3ea36e77.efs.us-east-1.amazonaws.com:/'
    - fstype: nfs
    - persist: True
    - mkmnt: True
    {% elif salt['grains.get']('ec2:placement:availability_zone') == 'us-east-1b' %}
    - device: 'us-east-1b.fs-3ea36e77.efs.us-east-1.amazonaws.com:/'
    - fstype: nfs
    - persist: True
    - mkmnt: True
    {% endif %}

# Create website directory structure

/mnt/efs/web/joshbolling.com:
  file.directory:
    - user: apache
    - group: apache
    - require:
      - mount: /mnt/efs/web # Require EFS filesystem is mounted before attempting to create the directory

/mnt/efs/web/joshbolling.com/blog:
  file.directory:
    - user: apache
    - group: apache
    - require:
      - mount: /mnt/efs/web # Require EFS filesystem is mounted before attempting to create the directory

# Download Wordpress files for joshbolling.com

wget -P /mnt/efs/web/joshbolling.com  https://wordpress.org/latest.tar.gz:
  cmd.run:
    - creates:
      - /mnt/efs/web/joshbolling.com/latest.tar.gz
    - require:
      - file: /mnt/efs/web/joshbolling.com

# Download Wordpress files for joshbolling.com/blog (the tarball downloaded above can be extracted again. Removing in next version.)

wget -P /mnt/efs/web/joshbolling.com/blog  https://wordpress.org/latest.tar.gz:
  cmd.run:
    - creates:
      - /mnt/efs/web/joshbolling.com/blog/latest.tar.gz
    - require:
      - file: /mnt/efs/web/joshbolling.com/blog

# Extract compressed Wordpress archives (joshbolling.com)

tar -zxf /mnt/efs/web/joshbolling.com/latest.tar.gz -C /mnt/efs/web/joshbolling.com/:
  cmd.run:
    - creates:
      - /mnt/efs/web/joshbolling.com/wordpress

# Extract compressed Wordpress archives (joshbolling.com/blog)

tar -zxf /mnt/efs/web/joshbolling.com/blog/latest.tar.gz -C /mnt/efs/web/joshbolling.com/blog/:
  cmd.run:
    - creates:
      - /mnt/efs/web/joshbolling.com/blog/wordpress

# Move files from Wordpress extraction directory to appropriate directories (joshbolling.com)

mv /mnt/efs/web/joshbolling.com/wordpress/* /mnt/efs/web/joshbolling.com/:
  cmd.run:
    - creates:
      - /mnt/efs/web/joshbolling.com/license.txt
    - require:
      - cmd: tar -zxf /mnt/efs/web/joshbolling.com/latest.tar.gz -C /mnt/efs/web/joshbolling.com/

# Move files from Wordpress extraction directory to appropriate directories (joshbolling.com/blog)

mv /mnt/efs/web/joshbolling.com/blog/wordpress/* /mnt/efs/web/joshbolling.com/blog/:
  cmd.run:
    - creates:
      - /mnt/efs/web/joshbolling.com/blog/license.txt
    - require:
      - cmd: tar -zxf /mnt/efs/web/joshbolling.com/blog/latest.tar.gz -C /mnt/efs/web/joshbolling.com/blog/

# Change ownership of Wordpress files

/mnt/efs/web/joshbolling.com/:
  file.directory:
    - user: apache
    - group: apache
    - dir_mode: 750
    - file_mode: 640
    - recurse:
      - user
      - group
      - mode

/mnt/efs/web/joshbolling.com/blog/:
  file.directory:
    - user: apache
    - group: apache
    - dir_mode: 750
    - file_mode: 640
    - recurse:
      - user
      - group
      - mode

# Ensure HTTPD service is running

start_and_enable_httpd:
  service.running:
    - name: httpd
    - enable: true
    - require:
        - pkg: install_httpd # Require HTTPD package to be installed
        - mount: /mnt/efs/web # require EFS volume is mounted
        - file: /var/www/html # Require /var/www/html symlink. Apache won't start without a valid DocumentRoot.

remove_default_html_directory:
  file.absent:
    - name: /var/www/html
    - onlyif:
      - stat /var/www/html | grep -i "directory" # Only remove this object if it's a directory

/var/www/html:
  file.symlink:
    - target: /mnt/efs/web/joshbolling.com
    - require:
        - file: remove_default_html_directory # Only create the symlink if it doesn't already exist.

# Ensure salt-minion service is running and enabled on managed nodes

start_and_enable_salt_minion_service:
  service.running:
    - name: salt-minion
    - enable: true
    - watch:
        - file: /etc/salt/minion

# Ensure minion configuration file is present and managed

ensure_minion_configuration_file_is_present:
  file.exists:
    - name: /etc/salt/minion

# Ensure Wordpress configuration files are present and managed

ensure_joshbolling_com_Wordpress_configuration_file_is_present:
  file.managed:
    - name: /mnt/efs/web/joshbolling.com/wp-config.php
    - source: salt://configuration_files/wp-config_joshbolling.com.php

ensure_joshbolling_com_Wordpress_blog_configuration_file_is_present:
  file.managed:
    - name: /mnt/efs/web/joshbolling.com/blog/wp-config.php
    - source: salt://configuration_files/wp-config_joshbolling.com_blog.php

# Ensure PHP configuration file is present and managed

ensure_PHP_configuration_file_is_present:
  file.managed:
    - name: /etc/php.ini
    - source: salt://configuration_files/php.ini


