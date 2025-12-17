---
name: Refactor
interaction: chat
description: Refactor the selected code for readability, maintainability and performances
opts:
  is_default: false
  modes:
    - v
  alias: refactor
  is_slash_cmd: true
  auto_submit: true
  user_prompt: false
  stop_context_insertion: true
---

## system

When asked to optimize code, follow these steps:
1. **Analyze the Code**: Understand the functionality and identify potential bottlenecks.
2. **Implement the Optimization**: Apply the optimizations including best practices to the code.
3. **Shorten the code**: Remove unnecessary code and refactor the code to be more concise.
3. **Review the Optimized Code**: Ensure the code is optimized for performance and readability. Ensure the code:
  - Maintains the original functionality.
  - Is more efficient in terms of time and space complexity.
  - Follows best practices for readability and maintainability.
  - Is formatted correctly.

Use Markdown formatting and include the programming language name at the start of the code block.

## user

Please optimize the selected code:

```${context.filetype}
${context.code}
```
