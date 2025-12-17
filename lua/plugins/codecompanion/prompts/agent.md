---
name: agent
interaction: inline
description: AI agent inline completion
opts:
  adapter:
    name: copilot
    model: gpt-5-mini
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

You are an expert programmer. Provide concise, working code solutions. Return only the code, no explanations unless specifically asked.

## user

File context: #{buffer}

Selected code:
```${context.filetype}
${context.code}
```
