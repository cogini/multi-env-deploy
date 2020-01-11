# iptables-http

Configure iptables to allow access to HTTP server and redirect external HTTP
port to app port.

# Requirements

This should be run after the `iptables` role, which sets `iptables_raw`.

# Role Variables

Port that app listens on
```yaml
iptables_http_app_port_http: 4000
iptables_http_app_port_https: 4001
```

HTTP public port
```yaml
iptables_http_external_port_http: 80
iptables_http_external_port_https: 443
```

Whether to open external ports:
```yaml
iptables_http_open_http: false
iptables_http_open_https: false
```

Whether to redirect external port to listen port
```yaml
iptables_http_redirect_http: true
iptables_http_redirect_https: false
```

Whether to rate limit inbound HTTP connections
```yaml
iptables_http_rate_limit_http: false
iptables_http_rate_limit_https: false
```

Rate limit options
```yaml
iptables_http_rate_limit_options_http: "-m hashlimit --hashlimit-name HTTP --hashlimit 5/minute --hashlimit-burst 10 --hashlimit-mode srcip --hashlimit-htable-expire 300000"
iptables_http_rate_limit_options_https: "-m hashlimit --hashlimit-name HTTPS --hashlimit 5/minute --hashlimit-burst 10 --hashlimit-mode srcip --hashlimit-htable-expire 300000"
```

# Example Playbook

```yaml
- hosts: '*'
  become: true
  roles:
     - iptables
     - iptables-http
```

# License

MIT

# Author Information

Jake Morrison <jake@cogini.com>
