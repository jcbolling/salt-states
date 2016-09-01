#######################################################################################
#                                                                                     #
# Author: Josh Bolling (http://joshbolling.com)                                       #
#                                                                                     #
# Date: 8/22/2016                                                                     #
#                                                                                     #
# State name: database-rds                                                            #
#                                                                                     #
# Version: 1.0                                                                        #
#                                                                                     #
# Description: This state appends MySQL connection information to the minion          #
# configuration file, creates separate MySQL databases for two Wordpress installs,    #
# creates a unique user for each database and grants those users appropriate          #
# permissions on those databases. This state should only be called during a           #
# greenfield installation in a new AWS region.                                        #
#                                                                                     #
#######################################################################################

append_MySQL_connection_information_to_minion_configuration_file:
  file.append:
    - name: /etc/salt/minion
    - text:
      - "mysql.host: '<MySQL server hostname or IP address goes here>'"
      - "mysql.port: <MySQL port number goes here>"
      - "mysql.user: '<MySQL connection username goes here>'"
      - "mysql.pass: '<MySQL connection password goes here>'"
      - "mysql.db: 'mysql'"
      - "mysql.charset: 'utf8'"

# Create databases for website and Blog

<Database name goes here>:
  mysql_database.present

<Database name goes here>:
  mysql_database.present

# Create users to be used by Wordpress to connect to MySQL

<MySQL user account used to access this database goes here>:
  mysql_user.present:
    - host: '%'  # Wildcard used so instances created during a scaling event can access RDS. Access control implemented in SGs.
    - password: '<MySQL password for user specified above goes here>'
    - require:
      - file: append_MySQL_connection_information_to_minion_configuration_file # Ensure instance can has connection information

<MySQL user account used to access this database goes here>:
  mysql_user.present:
    - host: '%'  # Wildcard used so instances created during a scaling event can access RDS. Access control implemented in SGs.
    - password: 'MySQL password for user specified above goes here>'
    - require:
      - file: append_MySQL_connection_information_to_minion_configuration_file # Ensure instance has connection information

# Grant users privileges on their respective databases

<Unique state ID goes here>:
  mysql_grants.present:
    - grant: all privileges
    - database: <Target database name goes here>.*
    - user: <User account to which privileges should be granted goes here>
    - host: '%'  # Wildcard used so instances created during a scaling event can access RDS. Access control implemented in SGs.
    - require:
      - file: append_MySQL_connection_information_to_minion_configuration_file # Ensure instance has connection information

<Unique state ID goes here>:
  mysql_grants.present:
    - grant: all privileges
    - database: <Target database name goes here>.*
    - user: <User account to which privileges should be granted goes here>
    - host: '%'  # Wildcard used so instnaces created during a scaling event can access RDS. Access control implemented in SGs.
    - require:
      - file: append_MySQL_connection_information_to_minion_configuration_file # Ensure instance has connection information
