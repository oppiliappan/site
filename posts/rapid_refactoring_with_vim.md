Last weekend, I was tasked with refactoring the 96 unit
tests on
[ruma-events](https://github.com/ruma/ruma-events/pull/70)
to use strictly typed json objects using `serde_json::json!`
instead of raw strings.  It was rather painless thanks to
vim :)

Here's a small sample of what had to be done (note the lines
prefixed with the arrow):

```rust
→ use serde_json::{from_str};
  
  #[test]
  fn deserialize() {
    assert_eq!(
→       from_str::<Action>(r#"{"set_tweak": "highlight"}"#),
        Action::SetTweak(Tweak::Highlight { value: true })
        );
  }
```

had to be converted to:

```rust
→ use serde_json::{from_value};
  
  #[test]
  fn deserialize() {
    assert_eq!(
→       from_value::<Action>(json!({"set_tweak": "highlight"})),
        Action::SetTweak(Tweak::Highlight { value: true })
        );
  }
```

### The arglist

For the initial pass, I decided to handle imports, this was
a simple find and replace operation, done to all the files
containing tests. Luckily, modules (and therefore files)
containing tests in Rust are annotated with the
`#[cfg(test)]` attribute. I opened all such files:

```bash
# `grep -l pattern files` lists all the files
#  matching the pattern

vim $(grep -l 'cfg\(test\)' ./**/*.rs)

# expands to something like:
vim push_rules.rs room/member.rs key/verification/lib.rs
```

Starting vim with more than one file at the shell prompt
populates the arglist.  Hit `:args` to see the list of
files currently ready to edit. The square [brackets]
indicate the current file.  Navigate through the arglist
with `:next` and `:prev`. I use tpope's vim-unimpaired
[^un], which adds `]a` and `[a`, mapped to `:next` and
`:prev`.

[^un]: https://github.com/tpope/vim-unimpaired
  It also handles various other mappings, `]q` and `[q` to
  navigate the quickfix list for example

All that's left to do is the find and replace, for which we
will be using vim's `argdo`, applying a substitution to
every file in the arglist:

```
:argdo s/from_str/from_value/g
```

### The quickfix list

Next up, replacing `r#" ... "#` with `json!( ... )`. I
couldn't search and replace that trivially, so I went with a
macro call [^macro] instead, starting with the cursor on
'r', represented by the caret, in my attempt to breakdown
the process:

[^macro]: `:help recording`

```
BUFFER:    r#" ... "#;
           ^

ACTION:    vllsjson!(

BUFFER     json!( ... "#;
                ^

ACTION:    <esc>$F#

BUFFER:    json!( ... "#;
                       ^

ACTION:    vhs)<esc>

BUFFER:    json!( ... );
```

Here's the recorded [^rec] macro in all its glory:
`vllsjson!(<esc>$F#vhs)<esc>`. 

[^rec]: When I'm recording a macro, I prefer starting out by
  storing it in register `q`, and then copying it over to
  another register if it works as intended. I think of `qq` as
  'quick record'.

Great! So now we just go ahead, find every occurrence of
`r#` and apply the macro right? Unfortunately, there were
more than a few occurrences of raw strings that had to stay
raw strings. Enter, the quickfix list.

The idea behind the quickfix list is to jump from one
position in a file to another (maybe in a different file),
much like how the arglist lets you jump from one file to
another.

One of the easiest ways to populate this list with a bunch
of positions is to use `vimgrep`:

```
# basic usage
:vimgrep pattern files

# search for raw strings
:vimgrep 'r#' ./**/*.rs
``` 

Like `:next` and `:prev`, you can navigate the quickfix list
with `:cnext` and `:cprev`. Every time you move up or down
the list, vim indicates your index:

```
(1 of 131): r#"{"set_tweak": "highlight"}"#;
```

And just like `argdo`, you can `cdo` to apply commands to
*every* match in the quickfix list:

```
:cdo norm! @q
```

But, I had to manually pick out matches, and it involved
some button mashing.

### External Filtering

Some code reviews later, I was asked to format all the json
inside the `json!` macro. All you have to do is pass a
visual selection through a pretty json printer. Select the
range to be formatted in visual mode, and hit `:`, you will
notice the command line displaying what seems to be
gibberish:

```
:'<,'>
```

`'<` and `'>` are *marks* [^mark-motions]. More
specifically, they are marks that vim sets automatically
every time you make a visual selection, denoting the start
and end of the selection.

[^mark-motions]: `:help mark-motions`

A range is one or more line specifiers separated by a `,`:

```
:1,7       lines 1 through 7
:32        just line 32
:.         the current line
:.,$       the current line to the last line
:'a,'b     mark 'a' to mark 'b'
```

Most `:` commands can be prefixed by ranges. `:help
usr_10.txt` for more on that.

Alright, lets pass json through `python -m json.tool`, a
json formatter that accepts `stdin` (note the use of `!` to
make use of an external program):

```
:'<,'>!python -m json.tool
```

Unfortunately that didn't quite work for me because the
range included some non-json text as well, a mix of regex
and macros helped fix that. I think you get the drift.

Another fun filter I use from time to time is `:!sort`, to
sort css attributes, or `:!uniq` to remove repeated imports.

