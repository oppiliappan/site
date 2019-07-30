a couple of nifty tricks to help you copy-paste better:

1. reselecting previously selected text (i use this to fix botched selections):

    ```
    gv  " :h gv for more
        " you can use `o` in visual mode to go to the `Other` end of the selection
        " use a motion to fix the selection
    ```

2. reselecting previously yanked text:

    ```
    `[v`]
    `[         " marks the beginning of the previously yanked text   :h `[
    `]         " marks the end                                       :h `]
     v         " visual select everything in between

    nnoremap gb `[v`]    " "a quick map to perform the above
    ```

3. pasting and indenting text (in one go):

    ```
    ]p   " put (p) and adjust indent to current line
    ]P   " put the text before the cursor (P) and adjust indent to current line
    ```
