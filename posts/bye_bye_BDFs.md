Glyph Bitmap Distribution Format is no more, as the creators of
[Pango](https://pango.org), one of the most widely used text rendering
libraries,
[announced](https://blogs.gnome.org/mclasen/2019/05/25/pango-future-directions/)
their plans for Pango 1.44.

Until recently, Pango used FreeType to draw fonts. They will be moving over
to [Harfbuzz](https://harfbuzz.org), an evolution of FreeType.

*Why?*

In short, FreeType was hard to work with. It required complex logic, and 
provided no advantage over Harfbuzz (other than being able to fetch
opentype metrics with ease).

Upgrading to Pango v1.44 will break your GTK applications (if you use a
`bdf`/`pcf` bitmap font). Harfbuzz *does* support bitmap-only OpenType fonts,
`otb`s. Convert your existing fonts over to `otb`s using
[FontForge](https://fontforge.github.io). It is to be noted that applications
such as `xterm` and `rxvt` use `xft` (X FreeType) to render fonts, and will
remain unaffected by the update.

Both [scientifica](https://github.com/nerdypepper/scientifica) and
[curie](https://github.com/nerdypepper/curie) will soon ship with bitmap-only
OpenType font formats.
