#! /usr/bin/env bash


post_title() {
    # remove extension
    # snake to title case
    echo "$1" | sed -E -e "s/\..+$//g"  -e "s/_(.)/ \u\1/g" -e "s/^(.)/\u\1/g"
}

post_wrapper() {
    # 1 - post id
    # 2 - post content
    title="$( post_title $1 )"
    echo -ne "
    <div class=\"post\">
        <div class=\"date\">$3</div>
        <a id=\"post-$1\" href=\"#$1\" class=\"post-link\" onClick=\"showPost('$1')\" >$title</a>
        <div id=\"$1\" class=\"post-text\" style=\"display: none\">
            $2
            <a href=\"#$1\" class=\"post-end-link\" onClick=\"showPost('$1')\">↑ Collapse</a>
            <div class="separator"></div>
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
<meta property=\"og:url\" content=\"https://nerdypepper.me\">
<title>n</title>
" > ./docs/index.html

# script
echo '<script>' >> docs/index.html
for s in ./script/*; do
    cat "$s" >> docs/index.html
done
echo '</script> </head>' >> docs/index.html

# body
echo "
<body onload=\"gotoId()\">
<h1 class=\"heading\">n</h1>
" >> docs/index.html


# begin posts
echo "
<div class=\"posts\">
" >> docs/index.html

# posts
posts=$(ls -t ./posts);
for f in $posts; do
    file="./posts/"$f
    echo "generating post $file"
    id="${file##*/}"    # ill name my posts just fine
    html=$(lowdown "$file")
    post_date=$(date -r "$file" "+%d/%m %Y")
    post_div=$(post_wrapper "$id" "$html" "$post_date")
    echo -ne "$post_div" >> docs/index.html
    first_visible="0"
done

echo "
</div>
</body>
</html>
" >> docs/index.html
