- Add docstrings
- Add unittests


- Summary
    - Undo / Redo
    - File save
    - Git
    - LSP events
    - Formatters
    - Unittests
    - File Created
    - File Renamed
    - Refactoring
    - Compile / Build information
    - Linting
    - Vim-isms

TODO add screenshot

- General
    - Add "View From Here" action
        - Allow restore from the view
    - Each entry should be aggregate (if they can be)
        - Also allow an expand / collapse tree
    - A plugin system so people can register their own sources
    - Need a command to package up a backup (for github issues)
        - Allow users to exclude certain histories (security)
    - Hover popup - https://youtu.be/68mvuBXTsQ0?si=wQR9FhYKpBzossOZ&t=47 (K mapping, maybe?)
        - Allow arbitrary notes / tagging on data and show it here
    - Code actions / right click (Select for compare)
    - Compare previous
    - Configuration options - allow users to configure what is saved (security)
    - Maybe need to batch stuff together
    - Actions
        - If the user selects multiple lines in visual mode
            - If not allowed, fail early
            - Otherwise
                - If multiple types of records were selected, prompt the user to select one type
                - Then run the action based on the selection

- Configuration
    - Allow a different format for displaying datetime
    - Allow people to change the date timezone


- Restore
    - Comes in place of a file save
    - Uses global git repository
- Undo / Redo
    - If possible, store information about the previous position in the ShaDa tree?
- File save
    - "Restore from current window" option
    - If no changes, don’t commit anything
        - Configurable (you can turn this on, but off by default)
- Git
    - General
        - A top, thin buffer with an overview of changes would be good
        - These edits would be either written as a manifest into the global git repository, fully copied, or managed dynamically. Not sure which is best. Dynamic, probably
            - If dynamic, the timeline view is a literal view into a query (based on window height)
                - Would need to know how many things to query
            - If dynamic, this code will need to check for rebases that could cause the commits to mess up and, if found, prompt the user to recompute the repository
                - .git/logs/refs/remotes/origin/<branch> has info
                - https://stackoverflow.com/a/16200487
    - Commits
        - Needs before / after commit (which it can get by querying, I guess)
            - "Restore from current window" option
        - Probably requires a third-party tie-in
        - This would use the local git repository, not the global one
        - This would only show in a file’s history if it actually touches the file
        - On-Hover - show git log information (author, datetime, message, etc)
            - https://youtu.be/xCikyLOzHOY?si=-lNDhDld8Q8ZDIi3&t=176
        - Actions:
            - Copy commit message
            - Copy commit author
            - Copy commit date
            - Copy commit ID
    - Push
        - Shows a diff between the current and the previous commit that wasn’t pushed, compared to the remote
            - Would need to show the remote’s details (remote name, URL, etc)
    - Force-Push
        - Same as push, but different icon / display
    - Merge
        - Actions
            - Allow selecting the remote / pull request based on K mapping
            - Also allow as code actions
    - Pull
        - Would need to update the global git repository based on file changes
        - So the next file save doesn’t clobber the new diff
    - Checkout
        - Would need to update the global git repository based on file changes
            - So the next file save doesn’t clobber the new diff
    - Stash
        - Would need to update the global git repository based on file changes
            - So the next file save doesn’t clobber the new diff
    - Changed Externally
        - Diff the current file against its latest in the global git. If change, record it as an external edit
            - Record this edit as a git commit in the global repository
        - Vim probably has an autocmd for external changes. Use this, too
        - Uses global git repository
        - A catch-all in case something goes wrong
- LSP events - workspace edited
    - Would likely show a log of the changes, not a diff
    - Probably requires a third-party tie-in
    - Uses global git repository, probably
- Formatters applied
    - Needs before / after copy
        - "Restore from current window" option
    - Probably requires a third-party tie-in
    - Uses global git repository
- File Renamed
    - Shows log (file permissions, owner, etc)
    - Probably requires a third-party tie-in
    - Uses global local OR git repository, probably
- File Created
    - Shows log (file permissions, owner, etc)
    - Can be built-in
    - Uses global git repository
- Tests successful / Failed
    - Quickfix showing the tests that succeed or failed
        - By default shows the file with the tests at that time
            - Probably requires tree-sitter to get the exact line numbers unless the tests themselves show it
    - Can map to current tests on-disk but would be experimental
    - Uses global git repository
- Code review
    - Comments added / replied
- Refactoring
    - Renaming a variable, extracting a method
- Compile/Build
    - Success / fail
        - Points to failing points at that particular point in history
- Code linting
    - Success / fail
        - Points to failing points at that particular point in history
- Multi-row timeline (by type)
    - `go` option would do the action most appropriate for the item
- Vim-isms
    - Macro recorded
        - TODO
    - Macro applied
        - TODO
    - Session loaded
        - TODO
    - Shell cmd ran
        - TODO

- Action
    - aggregate: boolean
    - callback: func(record[])
- Sources
    - Can read into a partial view (to quickly retrieve data)
        - Allowed to scroll up / down to get more information
- Records
    - datetime: string (I guess)
    - source: string or object (I guess)
    - label: string
    - actions (must be compatible with mappings)
        - Typical actions:
            - View details
                - Can be just a manifest or diffthis or both
            - Diffthis
                - Read only
                - Has a Restore to here mapping
            - Restore to here
            - Set quickfix (e.g. Show failed tests)
            - Set location list (e.g. Show failed tests)
    - type: string
    - id: GitCommit | string

- Split the "core" of this plugin which needs autocommands and any callbacks
  needed for specific events to a separate plugin
- Let the "UI" portion be separate

- Open (diff / summary)
    - Allows visual selection
- Open summary
    - Allows visual selection
- Show details
    - Allows visual selection


## Developing
```
w | lua require("plenary.reload").reload_module("timeline"); require("timeline").setup(); require("timeline.viewer").view_current()
```

## TODO
- Add FZF / Telescope integration when asking for a single record type.
  Otherwise, use Vim's built-in input function
- Make sure the Lua files and everything seem natural
- Figure out how to clean up the output of terminal.run
- Ask Neovim maintainers how to make pop-ups show above multiple windows at once (floating)
- Make the diff view better
    - You should be able to open, close, and reopen a diff
- Make the differ better. As diffoff should remove everything and not keep any buffers
- Wasn't there a new diff algorithm for Neovim? Try that
    - https://www.reddit.com/r/neovim/comments/stcml3/patience_diff_algorithm/
    - https://github.com/neovim/neovim/pull/14537
- Reduce the amount of closures used in the codebase
- Docstrings: How do you represent "anything" in Lua docstrings? object doesn't work
- Color-code the icons and record types
- Add a raw git diff option like with this
    - https://asciinema.org/a/397390
    - https://github.com/afnanenayet/diffsitter

- Update all functions that assume that it's running in the current buffer / window to not do that
    - e.g. all of action_triage.lua

- Change all terminal.run commands into lists
- Allow the timeline view to update as the user is working


- Make the diff view splitright when there's no existing window to work off of
- Move all uses of configuration.DATA to a variable that gets passed around to various functions, instead

- Maybe file.lua and git.lua can be combined
    - At least combine the caches into one
- Maybe it'd be better to make a diff in a separate tab? idk

- Allow people to toggle / filter / show record types in an existing timeline view without having to recompute everything all over again
- Make sure "restore" works as expected

- Speed
    - Do profiling and figure out how to get the code to be faster
    - Git commit diff is slow. Fix

refresh = {
    key = "r",
    command = action_triage.run_refresh_action,
    description = "[r]efresh the Timeline View buffer.",
},
- force refresh (clear all caches and refresh)
    - key = "R"

- Visual mode Timeline View unittest - make sure that it works for all visual modes
- Allow users to save Undo / Redo only on-file-save, if they want
- Check if I can auto-find a timezone
- Make configuration options more flexible (allow string, table, function, etc)
- Allow people to specify a custom git executable
- Allow missing source repositories in code. Make sure it doesn't error in the
  unittests (a source repository that has never been saved before is not an
  error)
- If "git init" is slow, consider doing it during setup() instead of the backup function


```json
{
    "extras": "arbitrary-stuff-here",
    "record_type": "blah"
}
