#! /usr/bin/env bash


title_wrapper() {
    # remove extension
    # snake to title case
    echo "$1" | sed -E -e "s/\..+$//g"  -e "s/_(.)/ \u\1/g" -e "s/^(.)/\u\1/g"
}

link_wrapper() {
    # 1 - id
    # 2 - title
    # 2 - date
    echo -ne "
    <div class=\"post\">
        <div class=\"date\">$3</div>
        <a href=\"/posts/$1.html\" class=\"post-link\">
            <span class=\"post-link\">$2</span>
        </a>
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
" >> docs/index.html


# begin posts
echo "
<div class=\"posts\">
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
    commit="$(git log -n1 --oneline "$file" | sed -e 's/\s.*$//g')"
    post_title=$(title_wrapper "$id")
    post_date=$(date -r "$file" "+%d/%m %Y")
    post_link=$(link_wrapper "${id%.*}" "$post_title" "$post_date")

    echo -ne "$post_link" >> docs/index.html

    esh -s /bin/bash \
        -o "docs/posts/${id%.*}.html" \
        "./post.esh" \
        file="$file" \
        date="$post_date" \
        commit="$commit" \
        title="$post_title"

    first_visible="0"
done

echo "
</div>
</body>
</html>
" >> docs/index.html
