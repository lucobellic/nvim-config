local adapter_utils = require('codecompanion.adapters.utils')
local auth = require('plugins.ai.codecompanion.adapters.http.codex.auth')
local constants = require('plugins.ai.codecompanion.adapters.http.codex.constants')
local log = require('codecompanion.utils.log')
local tool_utils = require('codecompanion.adapters.utils.tool_transformers')

-- Command to force login
vim.api.nvim_create_user_command('CodeCompanionCodexAuth', function(opts)
  local profile = opts.args
  local token_file = constants.get_token_path(profile)
  auth.authenticate(token_file)
end, {
  nargs = '?',
  desc = 'Authenticate with OpenAI Codex (ChatGPT Go/Plus/Pro). Optional: profile name',
})

local token_cache = {}

---Get a fresh access token (with in-memory caching)
---@param token_file string
---@return string|nil access_token
---@return string|nil account_id
local function get_fresh_token(token_file)
  local cache = token_cache[token_file] or { access_token = nil, account_id = nil, expires_at = 0 }

  if cache.access_token and os.time() < (cache.expires_at - 120) then
    return cache.access_token, cache.account_id
  end

  local refresh_token, cached_account_id = auth.load_token(token_file)

  if not refresh_token then
    vim.notify('Codex: Authentication required. Please run :CodeCompanionCodexAuth', vim.log.levels.WARN)
    return nil, nil
  end

  log:trace('Codex: Refreshing access token...')
  local data = auth.refresh_access_token(refresh_token)

  if not data then
    return nil, nil
  end

  -- Extract account_id from the new access token
  local account_id = auth.extract_account_id(data.access_token) or cached_account_id

  -- If we got a new refresh_token, persist it
  if data.refresh_token then
    local save_data = { refresh_token = data.refresh_token }
    if account_id then
      save_data.chatgpt_account_id = account_id
    end
    -- Save updated refresh token to disk
    auth.save_token(token_file, save_data)
  end

  token_cache[token_file] = {
    access_token = data.access_token,
    account_id = account_id,
    expires_at = os.time() + (data.expires_in or 3599),
  }

  log:trace('Codex: Token refreshed successfully')
  return data.access_token, account_id
end

-- =============================================================================
-- HELPERS
-- =============================================================================

---Provides the schemas of the tools available to the LLM
---@param self CodeCompanion.HTTPAdapter
---@param tools table<string, table>
---@return table|nil
local function transform_tools(self, tools)
  if not tools or vim.tbl_isempty(tools) then
    return nil
  end

  local transformed = {}

  for _, tool in pairs(tools) do
    for _, schema in pairs(tool) do
      if schema._meta and schema._meta.adapter_tool then
        if self.available_tools[schema.name] then
          self.available_tools[schema.name].callback(self, transformed)
        end
      else
        table.insert(
          transformed,
          tool_utils.transform_schema_if_needed(schema, {
            strict_mode = true,
          })
        )
      end
    end
  end

  return #transformed > 0 and transformed or nil
end

---Transform CodeCompanion messages to the OpenAI Responses API input format
---@param messages table[]
---@return table input items
---@return string|nil system instructions
local function transform_messages(self, messages)
  -- Collect system messages as instructions
  local instructions = vim
    .iter(messages)
    :filter(function(m) return m.role == 'system' end)
    :map(function(m) return m.content end)
    :totable()

  local system_instruction = #instructions > 0 and table.concat(instructions, '\n') or nil

  local input = {}
  local i = 1
  while i <= #messages do
    local m = messages[i]
    if m.role ~= 'system' then
      if m.role == 'function' then
        -- Tool result → function_call_output
        while i <= #messages and messages[i].role == 'function' do
          local current = messages[i]
          table.insert(input, {
            type = 'function_call_output',
            call_id = current.tools and current.tools.call_id or 'unknown',
            output = current.content or '',
          })
          i = i + 1
        end
        i = i - 1
      elseif m.tools and m.tools.calls then
        -- Assistant message with tool calls
        -- First add any text content
        if m.content and m.content ~= '' then
          table.insert(input, {
            type = 'message',
            role = 'assistant',
            content = {
              { type = 'output_text', text = m.content },
            },
          })
        end
        -- Then add each function call
        for _, tool_call in ipairs(m.tools.calls) do
          table.insert(input, {
            type = 'function_call',
            call_id = tool_call.id or ('call_' .. vim.uv.hrtime()),
            name = tool_call['function'].name,
            arguments = tool_call['function'].arguments or '{}',
          })
        end
      elseif m._meta and m._meta.tag == 'image' and (m.context and m.context.mimetype) then
        -- image message
        if self.opts and self.opts.vision then
          local next_msg = messages[i + 1]
          local combined_content = {
            {
              type = 'input_image',
              image_url = string.format('data:%s;base64,%s', m.context.mimetype, m.content),
            },
          }

          -- If next message is also from user with text content, combine them
          if next_msg and next_msg.role == m.role and type(next_msg.content) == 'string' then
            table.insert(combined_content, {
              type = 'input_text',
              text = next_msg.content,
            })
            i = i + 1 -- Skip the next message since we've combined it
          end

          table.insert(input, {
            role = m.role,
            content = combined_content,
          })
        else
          log:warn('Vision is not enabled for this adapter, skipping image message.')
        end
      elseif m.content and m.content ~= '' then
        local role = m.role == 'user' and 'user' or 'assistant'
        local content_type = role == 'user' and 'input_text' or 'output_text'
        table.insert(input, {
          type = 'message',
          role = role,
          content = {
            { type = content_type, text = m.content },
          },
        })
      end
    end
    i = i + 1
  end

  return input, system_instruction
end

local function resolve_model_opts(adapter)
  local model = adapter.schema.model.default
  local choices = adapter.schema.model.choices
  if type(model) == 'function' then
    model = model(adapter)
  end
  if type(choices) == 'function' then
    choices = choices(adapter)
  end

  return choices and choices[model] or { opts = {} }
end

---@param response table
---@return string|nil
local function extract_inline_output(response)
  if response.type == 'response.output_text.done' then
    return response.text
  end

  local output = response.output or (response.response and response.response.output)
  if not output then
    return nil
  end

  for _, item in ipairs(output) do
    if item.type == 'message' and item.content then
      for _, block in ipairs(item.content) do
        if block.type == 'output_text' and block.text then
          return block.text
        end
      end
    end
  end
end

-- =============================================================================
-- ADAPTER DEFINITION
-- =============================================================================
return {
  name = 'codex',
  formatted_name = 'Codex (ChatGPT)',
  roles = {
    llm = 'assistant',
    user = 'user',
    tool = 'function',
  },
  opts = {
    tools = true,
    stream = true,
    vision = true,
  },
  features = {
    text = true,
    tokens = true,
  },
  url = constants.API_BASE_URL .. '/codex/responses',
  env = {
    access_token = '',
    account_id = '',
  },
  headers = vim.tbl_extend('force', constants.HEADERS, {
    ['Authorization'] = 'Bearer ${access_token}',
    ['chatgpt-account-id'] = '${account_id}',
    ['Content-Type'] = 'application/json',
    ['Accept'] = 'text/event-stream',
  }),
  available_tools = {
    ['web_search'] = {
      description = 'Allow models to search the web for the latest information before generating a response.',
      enabled = true,
      ---@param self CodeCompanion.HTTPAdapter.OpenAIResponses
      ---@param tools table The transformed tools table
      callback = function(self, tools)
        table.insert(tools, {
          type = 'web_search',
        })
      end,
    },
  },
  handlers = {
    resolve = function(self)
      local token_file = constants.get_token_path(self.opts.profile)
      local refresh_token = auth.load_token(token_file)
      if not refresh_token then
        vim.schedule(function() auth.authenticate(token_file) end)
      end
    end,
    lifecycle = {
      setup = function(self)
        local token_file = constants.get_token_path(self.opts.profile)

        local access_token, account_id = get_fresh_token(token_file)
        if not access_token then
          return false
        end

        self.env.access_token = access_token
        self.env.account_id = account_id or ''

        if not account_id or account_id == '' then
          log:error(
            'Codex: Could not extract ChatGPT account ID from token. Re-authenticate with :CodeCompanionCodexAuth'
          )
          return false
        end

        local model_opts = resolve_model_opts(self)

        self.opts.vision = false

        if model_opts and model_opts.opts then
          self.opts = vim.tbl_deep_extend('force', self.opts, model_opts.opts)

          if model_opts.opts.has_vision then
            self.opts.vision = true
          end
        end
        return true
      end,
      ---@param self CodeCompanion.HTTPAdapter
      ---@param data? table
      on_exit = function(self, data)
        if data and data.status >= 400 then
          log:error('Codex: Error: %s', data.body)
        end
      end,
    },
    request = {
      ---@param self CodeCompanion.HTTPAdapter
      ---@param params table  { model, reasoning_effort, reasoning_summary, text_verbosity, ... }
      ---@param messages table
      ---@return table
      build_parameters = function(self, params, messages)
        -- model viene del schema mapping "parameters"
        local model = params.model
        if not model then
          model = self.schema.model.default
          if type(model) == 'function' then
            model = model(self)
          end
        end

        -- Construir objeto reasoning desde los params planos del schema
        local reasoning = nil
        if params.reasoning_effort then
          local effort = params.reasoning_effort
          -- "minimal" no soportado por el backend de ChatGPT
          if effort == 'minimal' then
            effort = 'low'
          end
          reasoning = {
            effort = effort,
            summary = params.reasoning_summary or 'auto',
          }
        end

        return {
          model = model,
          reasoning = reasoning,
          include = { 'reasoning.encrypted_content' },
          text = { verbosity = params.text_verbosity or 'medium' },
          store = false,
          -- The Codex backend accepts only streamed Responses API requests.
          stream = true,
        }
      end,
      ---@param self CodeCompanion.HTTPAdapter
      ---@param messages table
      ---@return table
      build_messages = function(self, messages)
        local input, system_instruction = transform_messages(self, messages)
        return {
          instructions = system_instruction,
          input = input,
        }
      end,
      ---@param self CodeCompanion.HTTPAdapter
      ---@param tools table<string, table>
      ---@return table|nil
      build_tools = function(self, tools)
        local tools_list = transform_tools(self, tools)
        if not tools_list then
          return nil
        end
        return { tools = tools_list }
      end,

      ---@param self CodeCompanion.HTTPAdapter
      ---@param payload table
      ---@return table
      build_body = function(self, payload) return {} end,
    },
    response = {
      ---@param self CodeCompanion.HTTPAdapter
      ---@param data table
      ---@param context? table
      ---@return {status: string, output: string}|nil
      parse_inline = function(self, data, context)
        if not data or not data.body then
          return { status = 'error', output = 'No output from the model' }
        end

        local ok, json = pcall(vim.json.decode, data.body, { luanil = { object = true } })
        local output = ok and extract_inline_output(json)
        if output then
          return { status = 'success', output = output }
        end

        for line in data.body:gmatch('[^\r\n]+') do
          local event = line:match('^data:%s*(.+)$')
          if event and event ~= '[DONE]' then
            local event_ok, event_json = pcall(vim.json.decode, event, { luanil = { object = true } })
            local event_output = event_ok and extract_inline_output(event_json)
            if event_output then
              return { status = 'success', output = event_output }
            end
          end
        end

        log:error('Codex: Error decoding inline response: %s', data.body)
        return { status = 'error', output = 'Invalid response from the model' }
      end,
      ---@param self CodeCompanion.HTTPAdapter
      ---@param data table
      ---@return number|nil
      parse_tokens = function(self, data)
        if not data or data == '' then
          return nil
        end

        local data_mod = adapter_utils.clean_streamed_data(data)
        local ok, json = pcall(vim.json.decode, data_mod, { luanil = { object = true } })

        if ok and json then
          local is_final = json.type == 'response.done' or json.type == 'response.completed'
          if is_final and json.response and json.response.usage then
            local usage = json.response.usage
            log:trace(
              'Codex: Tokens used — input: %s, output: %s, total: %s',
              usage.input_tokens,
              usage.output_tokens,
              usage.total_tokens
            )
            return usage.total_tokens
          end
        end
      end,
      parse_chat = function(self, data, tools)
        if not data or data == '' then
          return nil
        end

        local data_mod = adapter_utils.clean_streamed_data(data)
        local ok, json = pcall(vim.json.decode, data_mod, { luanil = { object = true } })

        if not ok or not json then
          return nil
        end

        local event_type = json.type

        -- Text delta
        if event_type == 'response.output_text.delta' then
          return {
            status = 'success',
            output = {
              role = 'assistant',
              content = json.delta or '',
            },
          }
        end

        -- Reasoning/thinking content
        if event_type == 'response.reasoning_summary_text.delta' then
          return {
            status = 'success',
            output = {
              role = 'assistant',
              reasoning = { content = json.delta or '' },
            },
          }
        end

        -- Function call arguments delta - accumulate in tools table
        if event_type == 'response.function_call_arguments.delta' then
          -- We'll handle function calls on the .done event
          return nil
        end

        -- A complete output item (text or function_call)
        if event_type == 'response.output_item.done' then
          local item = json.item
          if item and item.type == 'function_call' then
            table.insert(tools, {
              id = item.call_id or ('call_' .. vim.uv.hrtime()),
              type = 'function',
              ['function'] = {
                name = item.name,
                arguments = item.arguments or '{}',
              },
            })
            return {
              status = 'success',
              output = {
                role = 'assistant',
                content = nil,
              },
            }
          end
          return nil
        end

        -- Response completed
        if event_type == 'response.done' then
          return nil -- tokens are handled separately
        end

        return nil
      end,
    },
    tools = {
      format_calls = function(self, tools) return tools end,
      format_response = function(self, tool_call, output)
        return {
          role = self.roles.tool or 'tool',
          tools = {
            call_id = tool_call.id,
            name = tool_call['function'].name,
          },
          content = output,
          opts = { visible = false },
        }
      end,
    },
  },

  schema = {
    model = {
      order = 1,
      mapping = 'parameters',
      type = 'enum',
      desc = 'The Codex model to use. Requires a ChatGPT Go/Plus/Pro subscription.',
      default = 'gpt-5.5',
      choices = {
        ['gpt-5.6-sol'] = {
          formatted_name = 'GPT 5.6 Sol',
          opts = {
            can_reason = true,
            supports_xhigh = true,
            supports_max = true,
            supports_none = true,
            has_vision = true,
          },
        },
        ['gpt-5.6-terra'] = {
          formatted_name = 'GPT 5.6 Terra',
          opts = {
            can_reason = true,
            supports_xhigh = true,
            supports_max = true,
            supports_none = true,
            has_vision = true,
          },
        },
        ['gpt-5.6-luna'] = {
          formatted_name = 'GPT 5.6 Luna',
          opts = {
            can_reason = true,
            supports_xhigh = true,
            supports_max = true,
            supports_none = true,
            has_vision = true,
          },
        },
        ['gpt-5.5'] = {
          formatted_name = 'GPT 5.5',
          opts = { can_reason = true, supports_xhigh = true, supports_none = true, has_vision = true },
        },
        ['gpt-5.4'] = {
          formatted_name = 'GPT 5.4',
          opts = { can_reason = true, supports_xhigh = true, supports_none = true, has_vision = true },
        },
        ['gpt-5.4-mini'] = {
          formatted_name = 'GPT 5.4 Mini',
          opts = { can_reason = true, supports_xhigh = true, supports_none = true, has_vision = true },
        },
      },
    },
    reasoning_effort = {
      order = 2,
      mapping = 'parameters',
      type = 'string',
      optional = true,
      enabled = function(self)
        local model_opts = resolve_model_opts(self)
        return model_opts.opts and model_opts.opts.can_reason
      end,
      default = 'medium',
      desc = 'Reasoning effort level. Higher = more thorough but slower.',
      choices = function(self)
        local model_opts = resolve_model_opts(self)
        local opts = model_opts.opts or {}
        local c = { 'low', 'medium', 'high' }
        if opts.supports_none then
          table.insert(c, 1, 'none')
        end
        if opts.supports_xhigh then
          table.insert(c, 'xhigh')
        end
        if opts.supports_max then
          table.insert(c, 'max')
        end
        if opts.min_effort == 'medium' then
          -- remove "low" and "none"
          c = vim.tbl_filter(function(v) return v ~= 'low' and v ~= 'none' end, c)
        end
        return c
      end,
    },
    reasoning_summary = {
      order = 3,
      mapping = 'parameters',
      type = 'string',
      optional = true,
      default = 'auto',
      desc = 'How to summarize reasoning in the response.',
      choices = { 'auto', 'concise', 'detailed' },
    },
    text_verbosity = {
      order = 4,
      mapping = 'parameters',
      type = 'string',
      optional = true,
      default = 'medium',
      desc = 'Controls the verbosity of text output.',
      choices = { 'low', 'medium', 'high' },
    },
  },
}
