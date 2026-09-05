# my overlay

## packages

| package | description |
| --- | --- |
| `app-misc/cube` | spinning cube <br /> (and platonic solids) |
| `sys-apps/ninit` | small init system |
| `app-misc/nhttp` | minimal http server |
| `app-misc/vufetch` | very useful fetch <br /> (live ebuild only, <br /> no release yet) |
| `app-misc/claude-desktop` | ⚠️ PROPRIETARY ⚠️ <br /> repackaged Anthropic's <br /> official .deb | 

## usage

### with `eselect repository`

```sh
emerge --ask app-eselect/eselect-repository
eselect repository add nburch git https://github.com/noahburchell/nburch-overlay.git
emaint sync --repo nburch
```

### manually

create `/etc/portage/repos.conf/nburch.conf`:

```ini
[nburch]
location = /var/db/repos/nburch
sync-type = git
sync-uri = https://github.com/noahburchell/nburch-overlay.git
auto-sync = yes
```

then:

```sh
emaint sync --repo nburch
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
