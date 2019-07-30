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
        <a href=\"#$1\" class=\"post-link\" onClick=\"showPost('$1')\">$title</a>
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
<html lang="en">
<head>
<link rel="stylesheet" href="/style.css">
<meta charset="UTF-8">
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
<body>
<div class="black-circle">
    <h1 class="heading">n</h1>
</div>
<div class="posts">
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
done

echo "
</div>
</body>
</html>
" >> docs/index.html
