# fix-ts-var-hints.nvim

<!--toc:start-->

- [fix-ts-var-hints.nvim](#fix-ts-var-hintsnvim)

  - [Features](#features)
  - [Installation](#installation)
  - [Usage](#usage)
    - [Commands](#commands)
  - [Configuration](#configuration)
  - [How It Works](#how-it-works)
  - [Development](#development)
    - [File Structure](#file-structure)
    - [Contributing](#contributing)
  - [License](#license)
  - [Acknowledgements](#acknowledgements)
  - [Future Enhancements](#future-enhancements)
  - [Support](#support)
  <!--toc:end-->

  - [How It Works](#how-it-works)
  - [Development](#development)
    - [File Structure](#file-structure)
    - [Contributing](#contributing)
  - [License](#license)
  - [Acknowledgements](#acknowledgements)
  - [Future Enhancements](#future-enhancements)
  - [Support](#support)
  <!--toc:end-->

`fix-ts-var-hints.nvim` is a Neovim plugin that provides inline TypeScript and
JavaScript variable type hints using LSP. It offers an easy-to-read visual
representation of variable types directly in your code, enhancing the
development experience.

## Features

- **Type Inlay Hints**: Automatically displays type hints for variables in
  TypeScript and JavaScript files.
- **Hover-Based Extraction**: Uses LSP's hover information to extract type data.
- **Auto Updates**: Automatically updates inlay hints on file changes, buffer
  focus, and other common editing events.
- **Minimal Overhead**: Built for efficiency and minimalism.

## Installation

### Using [Lazy.nvim](https://github.com/folke/lazy.nvim)

To install using `Lazy.nvim`, add the following configuration:

```lua
{
  "yourusername/fix-ts-var-hints.nvim",
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('ts_inlay_hints').setup()
  end,
}
```

### Using [Packer.nvim](https://github.com/wbthomason/packer.nvim)

To install using `Packer.nvim`, add the following configuration to your
`init.lua` or `plugins.lua`:

```lua
use {
  "yourusername/fix-ts-var-hints.nvim",
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('ts_inlay_hints').setup()
  end,
}
```

## Usage

The plugin will automatically display inlay hints when you open or edit
TypeScript/JavaScript files (`*.ts`, `*.tsx`, `*.js`, `*.jsx`).

### Commands

- Inlay hints are updated automatically, but you can manually trigger them
  if needed:

```lua
:lua require('ts_inlay_hints').show_inlay_hints()
```

## Configuration

By default, the plugin doesn't require any configuration.
However, you can extend it by passing options to the `setup` function:

```lua
require('ts_inlay_hints').setup({
  -- Add configuration options here in the future if needed
})
```

## How It Works

- The plugin uses the LSP's `textDocument/documentSymbol` request to identify variables.
- It then uses the LSP's `textDocument/hover` request to extract type information.
- Inline type hints are displayed using Neovim's `virt_text` feature.

## Development

### File Structure

```text
fix-ts-var-hints.nvim/
  ├── lua/
  │   └── ts_inlay_hints/
  │       ├── init.lua       # Main entry point
  │       └── core.lua       # Core logic for inlay hints
  ├── plugin/
  │   └── ts_inlay_hints.lua  # Autocommand setup
  ├── README.md
  ├── LICENSE
```

### Contributing

1. Fork the repository.
2. Create a new branch for your feature: `git checkout -b my-new-feature`.
3. Make your changes.
4. Commit your changes: `git commit -am 'Add new feature'`.
5. Push to the branch: `git push origin my-new-feature`.
6. Create a new Pull Request.

## License

This plugin is licensed under the MIT License. See the [LICENSE](LICENSE)
file for more information.

## Acknowledgements

- Built using [Neovim's Lua API](https://neovim.io/doc/user/lua.html).
- Uses [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) for test support.
- Inspired by modern IDE inlay hints.

## Future Enhancements

- **Customizable Styles**: Options for customizing hint colors, styles, and placement.
- **Testing & CI**: Add comprehensive tests and integrate CI for consistent quality.
- **Configuration Options**: More granular control over what hints
  are displayed and when.

## Support

Feel free to open an issue on GitHub if you encounter bugs or have feature requests.
