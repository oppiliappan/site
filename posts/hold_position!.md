Often times, when I run a vim command that makes "big" changes to a file (a
macro or a `:vimgrep` command) I lose my original position and feel disoriented.

*Save position with `winsaveview()`!*

The `winsaveview()` command returns a `Dictionary` that contains information
about the view of the current window. This includes the cursor line number,
cursor coloumn, the top most line in the window and a couple of other values,
none of which concern us.

Before running our command (one that jumps around the buffer, a lot), we save
our view, and restore it once its done, with `winrestview`.

```
let view = winsaveview()
s/\s\+$//gc              " find and (confirm) replace trailing blanks
winrestview(view)        " restore our original view!
```

It might seem a little overkill in the above example, just use `` (double
backticks) instead, but it comes in handy when you run your file through
heavier filtering.

