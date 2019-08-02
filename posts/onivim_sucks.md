[Onivim](https://v2.onivim.io) is a 'modern modal editor', combining fancy
interface and language features with vim-style modal editing. What's wrong you
ask?

Apart from [buggy syntax highlighting](https://github.com/onivim/oni2/issues/550), 
[broken scrolling](https://github.com/onivim/oni2/issues/519) and
[others](https://github.com/onivim/oni2/issues?q=is%3Aissue+label%3A%22daily+editor+blocker%22+is%3Aopen),
Onivim is **proprietary** software. It is licensed under a commercial 
[end user agreement license](https://github.com/onivim/oni1/blob/master/Outrun-Labs-EULA-v1.1.md),
which prohibits redistribution in both object code and source code formats.

Onivim's core editor logic (bits that belong to vim), have been separated from
the interface, into [libvim](https://github.com/onivim/libvim). libvim is
licensed under MIT, which means, this 'extension' of vim is perfectly in
adherence to [vim's license text](http://vimdoc.sourceforge.net/htmldoc/uganda.html#license)! 
Outrun Labs are exploiting this loophole (distributing vim as a library) to
commercialize Onivim.

Onivim's source code is available on [GitHub](https://github.com/onivim/oni2).
They do mention that the source code trickles down to the
[oni2-mit](https://github.com/onivim/oni2-mit) repository, which (not yet) contains
MIT-licensed code, **18 months** after each commit to the original repository.

Want to contribute to Onivim? Don't. They make a profit out of your contributions.
Currently, Onivim is priced at $19.99, 'pre-alpha' pricing which is 80% off the
final price! If you are on the lookout for an editor, I would suggest using
[Vim](https://vim.org), charity ware that actually works, and costs $100 lesser.

