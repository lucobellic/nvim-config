---@class GitlabDuo.Adapter: CodeCompanion.Adapter
return {
  name = 'gitlab_duo',
  formatted_name = 'Gitlab Duo',
  roles = {
    llm = 'assistant',
    user = 'user',
    tool = 'tool',
  },
  opts = {
    tools = true,
  },
  features = {
    text = true,
    tokens = true,
  },
  url = '${url}${chat_url}',
  env = {
    api_key = 'GITLAB_TOKEN',
    url = 'https://gitlab.easymile.com',
    chat_url = '/api/v4/chat/completions',
  },
  headers = {
    ['Content-Type'] = 'application/json',
    ['Authorization'] = 'Bearer ${api_key}',
  },
  handlers = {
    tokens = function(self, data)
      if not data or data == '' then
        return nil
      end
      local ok, json = pcall(vim.json.decode, data.body)
      if not ok then
        return {
          status = 'error',
          output = 'Could not parse JSON response',
        }
      end
      if data and data.status >= 400 then
        return {
          status = 'error',
          output = json.error,
        }
      end
      -- JSON needs to have its backticks fixed. The Model reports
      -- that it cannot perform this action.
      if json == nil then
        vim.print(data)
      end
      if
        json
        == "I'm sorry, but answering this question requires a different Duo subscription. Please contact your administrator."
      then
        return {
          status = 'error',
          output = json,
        }
      end
      json = json:match('%*%*%* Begin Response%s*\n(.-)\n%s*%*%*%* End Response')
      json = json:gsub('`%s*`%s*`%s*`', '```')
      json = json:gsub('`%s*`%s*`', '```')
      json = json:gsub('"`', '"')
      data.body = json
      return require('codecompanion.adapters.http.openai').handlers.tokens(self, data)
    end,
    form_parameters = function(self, params, messages)
      return require('codecompanion.adapters.http.openai').handlers.form_parameters(self, params, messages)
    end,
    form_messages = function(self, messages)
      messages = vim
        .iter(messages)
        :filter(function(message) return message.content and message.content ~= '' end)
        :map(function(message)
          local gitlab_message = {
            category = 'file',
            id = message.role,
            content = message.content,
          }

          if message.tool_calls then
            gitlab_message.tool_calls = message.tool_calls
          end
          if message.tool_call_id then
            gitlab_message.tool_call_id = message.tool_call_id
          end

          return gitlab_message
        end)
        :totable()

      local message = {
        category = 'file',
        id = 'system',
        content = [[
Your Response Must:
1. Be wrapped in *** Begin Response / *** End Response markers"
2. Must be a serialized JSON-formatted OpenAI Response which has been minifiled before serialization.
3. The text requested by the propmt must be serialized as a string and inserted into the JSON-formatted OpenAI response.
If you're requested to return a JSON object:
1. The JSON must be represented as a string represented as %s in the following format:
```json
{
    "id": "chatcmpl-codecompanion-023",
    "object": "chat.completion",
    "created": 1703097716,
    "model": "codecompanion",
    "choices": [
        {
            "index": 0,
            "message": {
                "role": "assistant",
                "content": "%s"
            }
        }
    ],
    "finish_reason": "stop",
    "usage": {
        "prompt_tokens": 150,
        "completion_tokens": 600,
        "total_tokens": 750
    }
}
```
2. If the content field is not a valid json string because it ends with two double quotes, remove one of them.
]],
      }
      table.insert(messages, 1, message)

      return {
        content = 'Follow the messages in additional_context as instructed.',
        additional_context = messages,
      }
    end,
    form_tools = function(self, tools)
      return require('codecompanion.adapters.http.openai').handlers.form_tools(self, tools)
    end,
    chat_output = function(self, data, tools)
      if not data or data == '' then
        return nil
      end
      if self.opts and self.opts.tokens == false then
        local ok, json = pcall(vim.json.decode, data.body)
        if not ok then
          return {
            status = 'error',
            output = 'Could not parse JSON response',
          }
        end
        if data and data.status >= 400 then
          return {
            status = 'error',
            output = json.error,
          }
        end
        -- JSON needs to have its backticks fixed. The Model reports
        -- that it cannot perform this action.
        json = json:match('%*%*%* Begin Response%s*\n(.-)\n%s*%*%*%* End Response')
        json = json:gsub('`%s*`%s*`', '```')
        data.body = json
      end
      return require('codecompanion.adapters.http.openai').handlers.chat_output(self, data, tools)
    end,
    inline_output = function(self, data, context)
      if not data or data == '' then
        return nil
      end
      local ok, json = pcall(vim.json.decode, data.body)
      if not ok then
        return {
          status = 'error',
          output = 'Could not parse JSON response',
        }
      end
      if data and data.status >= 400 then
        return {
          status = 'error',
          output = json.error,
        }
      end
      -- JSON needs to have its backticks fixed. The Model reports
      -- that it cannot perform this action.
      json = json:match('%*%*%* Begin Response%s*\n(.-)\n%s*%*%*%* End Response')
      json = json:gsub('`%s*`%s*`', '```')
      data.body = json
      return require('codecompanion.adapters.http.openai').handlers.inline_output(self, data, context)
    end,
    tools = {
      format_tool_calls = function(self, tools)
        return require('codecompanion.adapters.http.openai').handlers.tools.format_tool_calls(self, tools)
      end,
      output_response = function(self, tool_call, output)
        return require('codecompanion.adapters.http.openai').handlers.tools.output_response(self, tool_call, output)
      end,
    },
  },
  schema = {
    model = {
      default = 'gitlab_duo',
    },
  },
}
