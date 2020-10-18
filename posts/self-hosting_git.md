Earlier this week, I began migrating my repositories from
Github to [cgit](https://git.zx2c4.com/cgit/about/). If you care at
all about big corporates turning open-source into a T-shirt
farming service, this is the way to go.

### Offerings

cgit is *very* bare bones. It is
[cgi-based](https://tools.ietf.org/html/rfc3875) web
interface to git, and nothing more. You may browse
repositories, view diffs, commit logs and even clone via
http. If you are looking to replace Github with cgit, keep
in mind that cgit does not handle issues or pull/merge
requests. If people wish to contribute to your work, they
would have to send you a patch via email. 

### Setup

Installing cgit is fairly straightforward, if you would
like to compile it from source:

```sh
# fetch
git clone https://git.zx2c4.com && cd cgit
git submodule init
git submodule update

# install
make NO_LUA=1
sudo make install
```

This would drop the cgit cgi script (and the default css)
into `/var/www/htdocs/cgit`. You may configure cgit by
editing `/etc/cgitrc`. I specify the `NO_LUA` flag to
compile without lua support, exclude that flag if you would
like to extend cgit via lua scripts.

### Going live

You might want to use,
[fcgiwrap](https://github.com/gnosek/fcgiwrap), a
[fastcgi](http://www.nongnu.org/fastcgi) wrapper for `cgi`
scripts,

```sh
sudo apt install fcgiwrap
sudo systemctl start fcgiwrap.socket
```

Expose the cgit cgi script to the web via `nginx`:

```
# nginx.conf
server {
  listen 80;
  server_name git.example.com;

  # serve static files
  location ~* ^.+\.(css|png|ico)$ {
    root /var/www/htdocs/cgit;
  }

  location / {
    fastcgi_pass  unix:/run/fcgiwrap.socket;
    fastcgi_param SCRIPT_FILENAME /var/www/htdocs/cgit/cgit.cgi; # the default location of the cgit cgi script
    fastcgi_param PATH_INFO       $uri;
    fastcgi_param QUERY_STRING    $args;
  }
}
```

Point cgit to your git repositories:

```
# /etc/cgitrc
scan-path=/path/to/git/repos
```

***Note***: *`scan-path` works best if you stick it at the end of your
`cgitrc`*.

You may now create remote repositories at
`/path/to/git/repos`, via: 

```
git init --bare
```

Add the remote to your local repository:

```
git remote set-url origin user@remote:/above/path
git push origin master
```

### Configuration

cgit is fairly easy to configure, all configuration
options can be found [in the
manual](https://git.zx2c4.com/cgit/tree/cgitrc.5.txt), here
are a couple of cool ones though:

**enable-commit-graph**: Generates a text based graphical
representation of the commit history, similar to `git log
--graph --oneline`.

```
| * |    Add support for configuration file
* | |    simplify command parsing logic
* | |    Refactor parsers
* | |    Add basic tests
* | |    Merge remote-tracking branch 'origin/master' in...
|\| |
| * |    add installation instructions for nix
| * |    switch to pancurses backendv0.2.2
| * |    bump to v0.2.2
* | |    Merge branch 'master' into feature/larger-names...
|\| |
| * |    enable feature based compilation to support win...
| * |    remove dependency on rustc v1.45, bump to v0.2....
| * |      Merge branch 'feature/windows' of https://git...
| |\ \
| | * |    add windows to github actions
| | * |    switch to crossterm backend
| | * |      Merge branch 'fix/duplicate-habits'
| | |\ \
| | | * |    move duplicate check to command parsing blo...
```

**section-from-path**: This option paired with `scan-path`
will automatically generate sections in your cgit index
page, from the path to each repo. For example, the directory
structure used to generate sections on [my cgit
instance](https://git.peppe.rs) looks like this:

```
├── cli
│   ├── dijo
│   ├── eva
│   ├── pista
│   ├── taizen
│   └── xcursorlocate
├── config
│   ├── dotfiles
│   └── nixos
├── fonts
│   ├── curie
│   └── scientifica
├── languages
│   └── lisk
├── libs
│   ├── cutlass
│   └── fondant
├── terminfo
├── university
│   └── furby
└── web
    └── isostatic
```

### Ease of use

As I mentioned before, `cgit` is simply a view into your git
repositories, you will have to manually create new
repositories by entering your remote and using `git init
--bare`. Here are a couple of scripts I wrote to perform
actions on remotes, think of it as a smaller version of
Github's `gh` program.

You may save these scripts as `git-script-name` and drop
them in your `$PATH`, and git will automatically add an
alias called `script-name`, callable via:

```
git script-name
```

#### git-new-repo

Creates a new repository on your remote,
the first arg may be a path (section/repo-name) or just the
repo name:

```
#! /usr/bin/env bash
#
# usage:
# git new-repo section/repo-name
# 
# example:
# git new-repo fonts/scientifica
# creates: user@remote:fonts/scientifica

if [ $# -eq 0 ]; then
    echo "requires an arg"
    exit 1
fi

ssh user@remote git init --bare "$1";
```


#### git-set-desc

To set a one line repository
description. It simply copies the local `.git/description`,
into `remote/description`. `cgit` displays the contents of
this file on the index page:

```
#! /usr/bin/env bash
#
# usage:
# enter repo description into .git/description and run:
# git set-desc 

remote=$(git remote get-url --push origin)
scp .git/description "$remote/description"
```
