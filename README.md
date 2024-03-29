# css-vars.nvim

**css-vars.nvim** - _autocompletion of CSS variables_

## :lock: Requirements

- [ripgrep](https://github.com/BurntSushi/ripgrep) (needs to be installed on your machine)

## :package: Installation

Install this plugin as a dependency to `hrsh7th/nvim-cmp`.

### [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
  "hrsh7th/nvim-cmp",
  dependencies = {
    -- other dependencies...
    {
      "jdrupal-dev/css-vars.nvim",
      opts = {},
    },
  },
  config = function()
     cmp.setup({
      -- Sources for autocompletion.
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "css_vars" },
        -- other sources...
      }),
    })
    -- more configuration...
  end
}
```

## :rocket: Features
This plugin scans your project for css vars using `ripgrep` and sets up the `css_vars`
completion source upon opening neovim.

If you add new CSS variables, you need to restart neovim for them to show in nvim-cmp.
