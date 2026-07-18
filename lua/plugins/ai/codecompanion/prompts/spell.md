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
    name: cocodex
    model: gpt-5.4-mini
---

## user

Correct grammar and reformulate:

${context.code}
