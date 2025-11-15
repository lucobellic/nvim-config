# Neovim Configuration - Agent Guidelines

## Commands

- **Lint**: `stylua --check .` (Lua formatting check)
- **Format**: `stylua .` (Lua formatting)
- **Spell check**: Runs automatically via cspell LSP integration

## Code Style

- **Indentation**: 2 spaces (no tabs)
- **Line width**: 120 characters max
- **Quotes**: Prefer single quotes (`quote_style = "AutoPreferSingle"`)
- **Function calls**: Always use parentheses (`call_parentheses = "Always"`)
- **Requires**: Auto-sorted with `sort_requires.enabled = true`

## File Structure

- Plugin configs in `lua/plugins/[category]/` (e.g., `completion/`, `editor/`, `ui/`)
- Main config in `lua/config/`
- Use lazy loading with `cmd`, `keys`, `ft` properties
- Import plugins by category in `lazy.lua:51-68`

## Conventions

- Return plugin spec tables from files: `return { 'plugin/name', opts = {} }`
- Use `opts` function for complex configuration
- Prefer `vim.tbl_deep_extend('force', opts, {})` for merging options
- Icons defined with Nerd Font symbols
- Use descriptive key mappings with `desc` field
