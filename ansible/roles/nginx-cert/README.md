# nginx-cert

Install Nginx SSL certificates from vault data.

# Requirements

None

# Role Variables

    nginx_cert_dir: /etc/nginx/ssl

Directory to install to. Will be created.

    nginx_cert_cert_path: "{{ nginx_cert_dir }}/server.crt"
    nginx_cert_key_path: "{{ nginx_cert_dir }}/server.crt"

Path to certs.

    nginx_cert_cert_data: ""
    nginx_cert_key_data: ""

The cert data should be defined in the vault

# Dependencies

None

# Example Playbook

```yaml
- hosts: servers
  roles:
     - nginx-cert
```

# License

BSD

# Author Information

Jake Morrison <jake@cogini.com>
