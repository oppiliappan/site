I am not an expert with fonts, but I do have some
experience [^exp], and common sense. This post aims to debunk some
misconceptions about font sizes!

[^exp]: https://github.com/nerdypepper/scientifica

11 px on your display is *probably not* 11 px on my display.
Let's do some quick math. I have two displays, 1366x768 @
21" and another with 1920x1080 @ 13", call them `A` and
`B` for now.

Display `A` has 1,049,088 pixels. A pixel is a square, of
side say, `s` cm. The total area covered by my 21" display
is about 1,066 cm^2 (41x26). Thus,

```
Display A
Dimensions: 1366x768 @ 21" (41x26 sq. cm)
1,049,088 s^2 = 1066
            s = 0.0318 cm (side of a pixel on Display A)
```

Bear with me, as I repeat the number crunching for Display
`B`:

```
Display B
Dimensions: 1920x1080 @ 13" (29.5x16.5 sq. cm)
2,073,600 s^2 = 486.75
            s = 0.0153 cm (side of a pixel on Display B)
```

The width of a pixel on Display `A` is *double* the width of a
pixel on Display `B`. The area occupied by a pixel on Display
`A` is *4 times* the area occupied by a pixel on Display `B`.

*The size of a pixel varies from display to display!*

A 5x11 bitmap font on Display `A` would be around 4 mm tall
whereas the same bitmap font on Display `B` would be around
1.9 mm tall. A 11 px tall character on `B` is visually
equivalent to a 5 px character on `A`. When you view a
screenshot of Display `A` on Display `B`, the contents are
shrunk down by a factor of 2!

So screen resolution is not enough, how else do we measure
size? Pixel Density! Keen readers will realize that the 5^th
grade math problem we solved up there showcases pixel
density, or, pixels per cm (PPCM). Usually we deal with
pixels per inch (PPI).

**Note:** PPI is not to be confused with DPI [^dpi] (dots
per inch). DPI is defined for printers.

[^dpi]: https://en.wikipedia.org/wiki/Dots_per_inch

In our example, `A` is a 75 ppi display and `B` is around
165 ppi [^ppi].  A low ppi display appears to be
'pixelated', because the pixels are more prominent, much
like Display `A`. A higher ppi usually means you can view
larger images and render crispier fonts. The average desktop
display can stuff 100-200 pixels per inch. Smart phones
usually fall into the 400-600 ppi (XXXHDPI) category. The
human eye fails to differentiate detail past 300 ppi.

*So ... streaming an 8K video on a 60" TV provides the same
clarity as a HD video on a smart phone?*

Absolutely. Well, clarity is subjective, but the amount of
detail you can discern on mobile displays has always been
limited.  Salty consumers of the Xperia 1 [^sony] will say
otherwise.

[^sony]: https://en.wikipedia.org/wiki/Sony_Xperia_1

Maybe I will talk about font rendering in another post, but
thats all for now. Don't judge a font size by its
screenshot.

[^ppi]: https://www.sven.de/dpi/

