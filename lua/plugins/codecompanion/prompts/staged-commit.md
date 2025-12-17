---
name: Generate a Commit Message for Staged Files
interaction: inline
description: staged file commit messages
opts:
  is_default: false
  is_slash_cmd: true
  alias: scommit
  auto_submit: true
---

## user

You are an expert at following the Conventional Commit specification. Given the git diff listed below, please generate a commit message for me:

```diff
${staged-commit.diff}
```
