---
name: Spell
interaction: inline
description: Correct grammar and reformulate
opts:
  is_default: false
  alias: spell
  is_slash_cmd: true
  auto_submit: true
  adapter:
    name: copilot
    model: gpt-4.1
---

## user

Correct grammar and reformulate:

${context.code}
