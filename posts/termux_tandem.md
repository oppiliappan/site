I learnt about `termux` from a friend on IRC recently.
It looked super gimmicky to me at first, but it eventually
proved to be useful. Here's what I use it for:

### rsync

Ever since I degoogled my android device, syncing files
between my phone and my PC has always been a pain. I'm
looking at you MTP. But, with `termux` and `sshd` all set up,
it's as simple as:

```
$ arp
Address         HWtype  HWad ...
192.168.43.187  ether   d0:0 ...

$ rsync -avz 192.168.43.187:~/frogs ~/pics/frogs
```

### ssh & tmux

My phone doubles as a secondary view into my main machine
with `ssh` and `tmux`. When I am away from my PC (read:
sitting across the room), I check build status and IRC
messages by `ssh`ing into a tmux session running the said
build or weechat.

### file uploads

Not being able to access my (ssh-only) file host was
crippling. With a `bash` instance on my phone, I just copied
over my ssh keys, and popped in a file upload script (a
glorified `scp`). Now I just have to figure out a way to
clean up these file names ...

```
~/storage/pictures/ $ ls
02muf5g7b2i41.jpg  7alt3cwg77841.jpg  cl4bsrge7id11.png
mtZabXG.jpg        p8d5c584f2841.jpg  vjUxGjq.jpg
```

### cmus

Alright, I don't really listen to music via `cmus`, but I
did use it a couple times when my default music player was
acting up. `cmus` is a viable option:

[![](https://u.peppe.rs/CP.jpg)](https://u.peppe.rs/CP.jpg)
