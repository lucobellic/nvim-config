---
name: Bug Finder
interaction: chat
description: Find potential bugs from the provided diff changes
opts:
  is_default: false
  alias: bugs
  is_slash_cmd: true
  auto_submit: true
---

## user

<question>
Check if there is any bugs that have been introduced from the provided diff changes.
Perform a complete analysis and do not stop at first issue found.
If available, provide absolute file path and line number for code snippets.
</question>

${bug-finder.diff_and_attach}
