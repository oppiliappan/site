#! /usr/bin/env bash


title_wrapper() {
    # remove extension
    # snake to title case
    echo "$1" | sed -E -e "s/\..+$//g"  -e "s/_(.)/ \u\1/g" -e "s/^(.)/\u\1/g"
}

read_time() {
    minu="$(eva -f 1 $1/150 | xargs)"
    echo "$minu"
}

height() {
    cm="$(eva -f 2 $1*18*0.0222 | xargs)"
    echo "$cm"
}

link_wrapper() {
    # 1 - id
    # 2 - title
    # 3 - date
    # 4 - read time
    echo -ne "
    <div class=\"post\">
        <div class=\"date\">
            $3
        </div>
        <a href=\"/posts/$1\" class=\"post-link\">
            <span class=\"post-link\">$2</span>
        </a>
        <div class="stats">
            <span class=\"stats-number\">
                $4
            </span>
            <span class="stats-unit">min</span>
        </div>
    </div>
    "
}

# meta
echo "
<!DOCTYPE html>
<html lang=\"en\">
<head>
<link rel=\"stylesheet\" href=\"./style.css\">
<meta charset=\"UTF-8\">
<meta name=\"viewport\" content=\"initial-scale=1\">
<meta content=\"#ffffff\" name=\"theme-color\">
<meta name=\"HandheldFriendly\" content=\"true\">
<meta property=\"og:title\" content=\"nerdypepper\">
<meta property=\"og:type\" content=\"website\">
<meta property=\"og:description\" content=\"a static site {for, by, about} me \">
<meta property=\"og:url\" content=\"https://nerdypepper.tech\">
<title>n</title>
" > ./docs/index.html

# body
echo "
<body>
<h1 class=\"heading\">n</h1>
<h4 class=\"date\">nerdypepper's μblog</h4>
" >> docs/index.html


# begin posts
echo "
<div class=\"posts\">
<div class="separator"></div>
" >> docs/index.html

# posts
posts=$(ls -t ./posts);
mkdir -p docs/posts

for f in $posts; do
    file="./posts/"$f
    echo "generating post $file"
    id="${file##*/}"    # ill name my posts just fine

    # generate posts
    html=$(lowdown "$file")
    stats=$(wc "$file")
    words="$(echo $stats | awk '{print $2}')"
    lines="$(echo $stats | awk '{print $1}')"

    r_time="$(read_time $words)"
    height="$(height $lines)"

    post_title=$(title_wrapper "$id")
    post_date=$(date -r "$file" "+%d/%m %Y")
    post_link=$(link_wrapper "${id%.*}" "$post_title" "$post_date" "$r_time" "$height")

    echo -ne "$post_link" >> docs/index.html

    id="${id%.*}"
    mkdir -p "docs/posts/$id"
    esh -s /bin/bash \
        -o "docs/posts/$id/index.html" \
        "./post.esh" \
        file="$file" \
        date="$post_date" \
        title="$post_title" \
        read_time="$r_time" \
        height="$height"

done

echo "
<div class="separator"></div>
<div class="footer">
    <a href="https://github.com/nerdypepper">Github</a>
    · 
    <a href="https://twitter.com/N3rdyP3pp3r">Twitter</a>
    · 
    <a href="mailto:nerdypepper@tuta.io">Mail</a>
    · 
    <a href="https://linkedin.com/in/nerdypepper">LinkedIn</a>
</div>
</div>
</body>
</html>
" >> docs/index.html
