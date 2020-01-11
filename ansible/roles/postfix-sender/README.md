# postfix-sender

This role is used for servers that run a local copy of Postfix to receive mail
from applications, then forward it to a delivery service such as AWS SES.

# Role Variables

`postfix_aliases` specifies mail aliases. Minimally, you should set up
an account which should get mail to root from misc programs.

    postfix_aliases:
      root: noc@example.com

`postfix_relayhost` specifies where outbound mail should go.

    postfix_relayhost: "[email-smtp.us-east-1.amazonaws.com]:2587"

`postfix_smtp_auth` specifies SMTP credentials for outbound mail:

    postfix_smtp_auth:
      - host: '{{ postfix_relayhost }}'
        user: 'AAA'
        pass: 'XXX'

`postfix_mailname` specifies the name of the host when sending mail.
This is only used on Debian, RedHat uses `gethostname()`.

    postfix_mailname: ""

# Dependencies

None

# Example Playbook

```yaml
- hosts: servers
  vars:
    postfix_aliases:
      root: noc@example.com
    postfix_relayhost: "[email-smtp.us-east-1.amazonaws.com]:2587"
    postfix_smtp_auth:
      - host: '{{ postfix_relayhost }}'
        user: 'AAA'
        pass: 'XXX'
  roles:
     - postfix-sender
 ```

# License

BSD

# Author Information

Jake Morrison <jake@cogini.com>
