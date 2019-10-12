I finally got around to installing Void GNU/Linux on my main
computer. Rolling release, non-systemd, need I say more?

As with all GNU/Linux distributions, wireless networks had
me in a fix. If you can see this post, it means I've managed
to get online. It turns out, `wpa_supplicant` was detecting the
wrong interface by default (does it ever select the right
one?). Let us fix that:

```
$ sudo rm -r /var/service/wpa_supplicant
$ sudo killall dhcpcd
```

What is the right interface though?

```
$ iw dev
   ...
   Interface wlp2s0
   ...
```

Aha! Let us run `wpa_supplicant` on that interface, as a
background process:

```
$ sudo wpa_supplicant -B -i wlp2s0 -c /etc/wpa_supplicant/wpa_supplicant.conf
$ sudo dhcpcd -B wlp2s0
$ ping google.com
PING ...
```

Yay! Make those changes perpetual by enabling the service:

```
------------------------------------------------------
# Add these to /etc/wpa_supplicant/wpa_supplicant.conf
OPTS="-B"
WPA_INTERFACE="wlp2s0"
------------------------------------------------------
$ sudo ln -s /etc/sv/wpa_supplicant /var/service/
$ sudo ln -s /etc/sv/dhcpcd /var/service/
$ sudo sv restart wpa_supplicant
$ sudo sv restart dhcpcd
```
