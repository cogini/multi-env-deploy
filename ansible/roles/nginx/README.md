# nginx

Install Nginx from repo at nginx.org or Ubuntu stable PPA.

This package installs Nginx but does not configure it.
Your package should install a customized Nginx configuration.

* Adds a logrotate config file
* Configures SELinux on RedHat

# Role Variables

Package state:

```yaml
nginx_package_state: present
```

To upgrade, set to `latest` temporarily.

Configure selinux:

```yaml
selinux_httpd_setrlimit: no
selinux_httpd_can_network_connect: no
selinux_httpd_can_network_relay: no
```

# Example Playbook

    - hosts: servers
      roles:
         - nginx

# License

BSD

# Author Information

Jake Morrison <jake@cogini.com>
