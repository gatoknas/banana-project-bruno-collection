---
trigger: always_on
---

# Sensitive Data & Secret Prevention (API Collections)

## Mandate
Never commit real API keys, bearer auth tokens, production passwords, or secret credentials directly into Bruno collection files (`*.bru`) or environment files.

## Rules & Best Practices
1. **Dynamic Secrets**: Use Bruno runtime environment variables or runtime prompt variables for sensitive secrets rather than committing them in plain text.
2. **Safe Placeholders**: When committing `.bru` files or shared environments, use placeholder tokens (e.g. `{{JWT_TOKEN}}`, `dummy_secret`).
