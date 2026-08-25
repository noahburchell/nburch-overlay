# my overlay

## packages

| package | description |
| --- | --- |
| `app-misc/cube` | spinning cube <br /> (and platonic solids) |
| `app-misc/nhttp` | minimal http server |
| `app-misc/vufetch` | very useful fetch <br /> (live ebuild only, <br /> no release yet) |
| `app-misc/claude-desktop` | ⚠️ PROPRIETARY ⚠️ <br /> repackaged Anthropic's <br /> official .deb | 

## usage

### with `eselect repository`

```sh
emerge --ask app-eselect/eselect-repository
eselect repository add noahburchell git https://github.com/noahburchell/noahburchell-overlay.git
emaint sync --repo noahburchell
```

### manually

create `/etc/portage/repos.conf/noahburchell.conf`:

```ini
[noahburchell]
location = /var/db/repos/noahburchell
sync-type = git
sync-uri = https://github.com/noahburchell/noahburchell-overlay.git
auto-sync = yes
```

then:

```sh
emaint sync --repo noahburchell
```

### installing

```sh
emerge --ask app-misc/cube
```

`app-misc/claude-desktop` is proprietary, so portage will refuse to merge it until you accept the licence:

```sh
echo 'app-misc/claude-desktop all-rights-reserved' >> /etc/portage/package.license
emerge --ask app-misc/claude-desktop
```
## contact

if you have any questions contact me: overlay@nburch.org

## license

GNU General Public License v3.
