install_php:
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