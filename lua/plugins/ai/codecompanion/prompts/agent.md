---
name: agent
interaction: inline
description: AI agent inline completion
opts:
  is_default: false
  alias: agent
  is_slash_cmd: false
  auto_submit: true
  user_prompt: true
  placement: replace
  stop_context_insertion: false
---

## system

```yaml
opts:
  visible: false
```

You are an expert programmer.
Provide concise, working code solutions.
Return only the code unless explanations are specifically requested.

## user

File context: #{buffer}

Selected code:

```${context.filetype}
${context.code}
```
