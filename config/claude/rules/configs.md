---
paths:
  - "**/*.{yaml,yml,json,jsonc,toml,tf,tfvars,hcl}"
  - "**/Dockerfile*"
---
No comments in config files. Explain intent in your message to me. The one exception is a value that looks wrong but isn't, in one short line.

- Keep the existing key order and grouping. Put new keys where a reader would look for them, not at the bottom.
- Secrets never go in config. Reference whatever env var or secret store the file already uses.
- Terraform: `terraform fmt`, `terraform validate`, then `terraform plan` if credentials are available. Never apply. Give me the plan summary and the command.
- Kubernetes and Helm: check with `kubectl diff` or `helm template`. Never apply.
