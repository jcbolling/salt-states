install_yum_utils:
  pkg.installed:
    - name: yum-utils

install_epel_release:
  pkg.installed:
    - name: epel-release

install_remi_repository:
  pkg.installed:
    - sources:
      - remi-release-7: http://rpms.remirepo.net/enterprise/remi-release-7.rpm

emable_remi_repository:
  cmd.run:
    - name: yum-config-manager --enable remi-php56

install_php_56:
  pkg.installed:
    - name: php
    - require:
      - pkg: install_yum_utils
      - pkg: install_epel_release
      - pkg: install_remi_repository
      - cmd: enable_remi_repository