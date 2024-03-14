# css-vars.nvim

**css-vars.nvim** - _autocompletion of CSS variables_

## :lock: Requirements

- [cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip)
- [ripgrep](https://github.com/BurntSushi/ripgrep) (needs to be installed on your machine)

## :package: Installation

Install this plugin using your favorite plugin manager, and then call
`require("css-vars").setup()`.

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "jdrupal-dev/css-vars.nvim",
  dependencies = {
    "saadparwaiz1/cmp_luasnip",
  },
  config = function()
    require("css-vars").setup()
  end,
}
```

## Limitations
This plugin scans your project for css vars using `ripgrep` and sets up the
luasnip snippets when starting neovim.

If you add new CSS variables, you need to restart neovim for them to show in nvim-cmp.
