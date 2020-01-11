# nginx-app

Configure Nginx as a proxy for an app.

## Requirements

None.

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

    nginx_app_proxy_ports:
      - 4000

Ports that the app listens on. If multiple ports are specified, Nginx will load balance between them.

    nginx_app_log_format: main

Log format. The default template defines two log formats, `main` and `json`.

    nginx_app_root: /var/www/html           # Ubuntu
    nginx_app_root: /usr/share/nginx/html   # CentOS

Root directory for serving static files. You would generally point that to the static files
directory inside your app, e.g. `/srv/foo/current/static`.

    nginx_app_ssl_on: false
    nginx_app_ssl_certificate_path: /etc/nginx/ssl/server.crt
    nginx_app_ssl_certificate_key_path: /etc/nginx/ssl/server.key

Enable SSL by setting `nginx_app_ssl_on: true`.

    nginx_app_limit_req_on: false
    nginx_app_limit_req_zone: "$binary_remote_addr zone=foo:10m rate=1r/s"
    nginx_app_limit_req: "zone=foo burst=5 nodelay"

Enable rate limiting by setting `nginx_app_limit_req_on: false`.

    nginx_app_systemd_override_template: etc/systemd/system/nginx.service.d/override.conf.j2
    nginx_app_nginx_conf_template: etc/nginx/nginx.conf.j2
    nginx_app_default_conf_template: etc/nginx/conf.d/default.conf.j2
    nginx_app_localhost_conf_template: etc/nginx/conf.d/localhost.conf.j2

Default template locations, defined as variables so they can be overridden.

If the default template does not suit your needs, you can replace it with yours:

* Create a `templates` directory at the same level as your playbook
* Create a `templates\whatever.j2` file (just choose a different name from the default template)
* In your playbook set the var `nginx_app_default_conf_template: whatever.j2`

# Dependencies

This role expects Nginx to already be installed.

# Example Playbook

```yaml
- hosts: servers
  roles:
     - nginx
     - nginx-app
```

# License

BSD

# Author Information

Jake Morrison <jake@cogini.com>
