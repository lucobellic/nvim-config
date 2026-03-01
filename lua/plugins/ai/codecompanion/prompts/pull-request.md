---
name: PullRequest
interaction: chat
description: Generate a Pull Request message description
opts:
  is_default: false
  alias: pr
  is_slash_cmd: true
  auto_submit: true
---

## user

You are an expert at writing detailed and clear pull request descriptions. Please create a pull request message following standard convention from the provided diff changes. Ensure the title, description, type of change, checklist, related issues, and additional notes sections are well-structured and informative.

```diff
${pull-request.diff}
```
