return {
  'SmiteshP/nvim-navbuddy',
  dependencies = {
    'SmiteshP/nvim-navic',
  },
  keys = {
    {
      '<leader>sl',
      function()
        require('nvim-navbuddy').open()
      end,
      desc = 'Navbuddy',
    },
  },
  opts = {
    window = { size = '80%' },
    lsp = { auto_attach = true },
  },
  config = function(_, opts)
    require('nvim-navbuddy').setup(opts)
    -- TODO: Find a proper way to do this with Lush
    -- Current Lush solution only provide `cleared` as result
    vim.cmd([[
          hi link NavbuddyArray         @punctuation
          hi link NavbuddyBoolean       @boolean
          hi link NavbuddyClass         @lsp.type.class
          hi link NavbuddyConstant      @constant
          hi link NavbuddyConstructor   @constructor
          hi link NavbuddyEnum          @lsp.type.enum
          hi link NavbuddyEnumMember    @lsp.type.enumMember
          hi link NavbuddyEvent         @field
          hi link NavbuddyField         @field
          hi link NavbuddyFunction      @function
          hi link NavbuddyInterface     @lsp.type.interface
          hi link NavbuddyKey           @keyword
          hi link NavbuddyMethod        @method
          hi link NavbuddyModule        @module
          hi link NavbuddyNamespace     @namespace
          hi link NavbuddyNull          @constant
          hi link NavbuddyNumber        @number
          hi link NavbuddyObject        @lsp.type.class
          hi link NavbuddyOperator      @operator
          hi link NavbuddyPackage       @namespace
          hi link NavbuddyProperty      @parameter
          hi link NavbuddyString        @string
          hi link NavbuddyStruct        @lsp.type.struct
          hi link NavbuddyTypeParameter @lsp.type.typeParameter
          hi link NavbuddyVariable      @variable
        ]])
  end,
}
