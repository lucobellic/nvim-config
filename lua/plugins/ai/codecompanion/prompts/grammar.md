---
name: Grammar
interaction: inline
description: Correct grammar
opts:
  is_default: false
  alias: grammar
  is_slash_cmd: true
  auto_submit: true
  adapter:
    name: copilot
    model: gpt-4.1
---

## user

Correct grammar as in the original language but keep the same meaning and formulation:

${context.code}
