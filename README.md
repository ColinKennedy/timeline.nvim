# timeline.nvim

View a file's changes in Neovim.

This plugins supports:

- File Related Changes
- Git
- LSP Events
- Formatters
- Unittests
- Refactoring
- Compile / Build information
- Linting
- Vim Events

TODO add videos / GIFs

## Installation
TODO: Fill all of this out


### Requirements
TODO add URL

- An installation of git


### Lazy.nvim
```lua
{
    "ColinKennedy/timeline.nvim",
    config = function()
        require("timeline").setup()
    end
    dependencies = {"nvim-lua/plenary.nvim"}
}
```

## Features
### File Related Changes
#### Changed Externally
#### File Created
#### File Renamed
#### File Saved
#### Undo / Redo

### Git
#### Checkout
#### Commits
#### Force-Push
#### Merge
#### Pull
#### Push
#### Stash

### LSP events
#### Workspace Changed
TODO

### Formatters applied

### Unittests
### Git Code Review
### Refactoring
### Compile / Build
### Code Linting


## Vim Events
### Macro recorded
### Macro applied
### Session loaded
### Shell cmd ran

## Views
- Multi-row timeline (by type)
    - `go` option would do the action most appropriate for the item
