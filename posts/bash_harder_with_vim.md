Bash is tricky, don't let your editor get in your way. Here's a couple of neat
additions you could make to your `vimrc` for a better shell programming
experience.


### Man pages inside vim
 Source this script to get started:  

```
runtime ftplugin/man.vim
```  
Now, you can open manpages inside vim with `:Man`! It adds nicer syntax highlighting
and the ability to jump around with `Ctrl-]` and `Ctrl-T`.

By default, the manpage is opened in a horizontal split, I prefer using a new tab:

```
let g:ft_man_open_mode = 'tab'
```


### Scratchpad to test your commands
I often test my `sed` substitutions, here is
a sample from the script used to generate this site:  

```
# a substitution to convert snake_case to Title Case With Spaces
echo "$1" | sed -E -e "s/\..+$//g"  -e "s/_(.)/ \u\1/g" -e "s/^(.)/\u\1/g"
```  
Instead of dropping into a new shell, just test it out directly from vim!

 - Yank the line into a register:

 ```
yy
 ```

 - Paste it into the command-line window:

 ```
q:p
 ```

 - Make edits as required:

 ```
syntax off            # previously run commands
edit index.html       # in a buffer!
w | so %
!echo "new_post.md" | sed -E -e "s/\..+$//g"  --snip--
^--- note the use of '!'
 ```

 - Hit enter with the cursor on the line containing your command!

 ```
$ vim
New Post         # output
Press ENTER or type command to continue
 ```

