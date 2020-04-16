After going through a bunch of static site generators
([pelican](https://blog.getpelican.com/),
[hugo](https://gohugo.io),
[vite](https://github.com/icyphox/vite)), I decided to roll
my own. If you are more of the 'show me the code' kinda guy,
[here](https://github.com/nerdypepper/site) you go.

### Text formatting
I chose to write in markdown, and convert
to html with [lowdown](https://kristaps.bsd.lv/lowdown/).

### Directory structure
I host my site on GitHub pages, so
`docs/` has to be the entry point. Markdown formatted posts
go into `posts/`, get converted into html, and end up in
`docs/index.html`, something like this:

```bash
posts=$(ls -t ./posts)     # chronological order!
for f in $posts; do
    file="./posts/"$f      # `ls` mangled our file paths
    echo "generating post $file"

    html=$(lowdown "$file")
    echo -e "html" >> docs/index.html
done
```

### Assets
Most static site generators recommend dropping image
assets into the site source itself. That does have it's
merits, but I prefer hosting images separately:

```bash
# strip file extension
ext="${1##*.}"

# generate a random file name
id=$( cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 2 | head -n 1 )
id="$id.$ext"

# copy to my file host
scp -P 443 "$1" emerald:files/"$id" 
echo "https://u.peppe.rs/$id"
```

### Templating
[`generate.sh`](https://github.com/NerdyPepper/site/blob/master/generate.sh)
brings the above bits and pieces together (with some extra
cruft to avoid javascript).  It uses `sed` to produce nice
titles from the file names (removes underscores,
title-case), and `date(1)` to add the date to each post
listing!
