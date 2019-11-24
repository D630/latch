##### README

I am on Debian GNU/Linux (testing/sid), and I use its software repository and package management system for installing the most part of my favourite utilities. Parallel to this, I build, install and "update" source packages coming from Git repositories, what is increasingly uncomfortable and produces the need of a way to manage this all. That is why I decided to write some simple shell scripts and to use them with git and [xstow](http://xstow.sourceforge.net/) as key tools.

You need a POSIX shell + "local" builtin command to make this business work properly.

##### USAGE

```
Subcommands
-----------
forge
    Manages the latchkey ring and its latchkeys:

    add                 Add a latchkey (Git branch) to the ring; create
                        a LINFO file and a LBUILD template.
                        $1 := URI
                        $2 := BRANCH
                        [ $3 := CONTEXT ]
    commit              Update the index and store changes in a new commit.
    remove              Destroy latchkey.
                        $1 := BRANCH
    ring                Initialize empty latchkey ring
                        (non-bare Git repository).

mr
    Clones and fetches code from the source code remote repositories:

    mirror              Mirror or update all configured repos (bare Git
                        repositories).

pkg
    Manages the installation of stow packages by putting source code repos and
    and latchkeys together:

    build               Build a source package by using the corresponding
                        latchkey (via LBUILD file).
                        $1 := BRANCH
                        [ $2 := <commit-ish of mirror> ]
                        [ $3 := <commit-ish of latchkey> ]
    chop                Delete all installed stow packages, but the stowed one.
                        $1 := BRANCH
    init                Initialize empty stow package directory
                        (non-bare Git repository).
                        $1 := BRANCH
    install             Install a build source package version into the
                        initialized stow package directory.
                        $1 := BRANCH
                        [ $2 := <commit-ish of mirror> ]
                        [ $3 := <commit-ish of latchkey> ]
    purge               Purge a stow package directory and all stow package
                        versions in it.
                        $1 := BRANCH
    remove              Remove/Delete a stow package version.
                        $1 := BRANCH
                        [ $2 := <commit-ish of mirror> ]
                        [ $3 := <commit-ish of latchkey> ]

rehash
    Reads the LINFO file from the master latchkey and records all keys and
    mirrors in the mirror.list file.

stow
    Link/Unlink installed stow packages into the system:

    add                 Stow a stow package into the stow target directory.
                        [ $1 := PKG_VERSION ]
    delete              Unstow the stowed stow package from the stow target
                        directory.
                        [ $1 := PKG_VERSION ]

Arguments
---------
    BRANCH                              Pathname of the URI:
                                        github.com/junegunn/fzf
    CONTEXT                             Determines the stow directory etc.:
                                        local | global | system
    URI                                 Remote or local uris:
                                        http://git.suckless.org/st
    PKG_VERSION                         <commit-ish of mirror>/<commit-ish of
                                        latchkey>:
                                        v2.4-3-g8c91196/fc88d0b
    <commit-ish of mirror>              See `git describe --always`
    <commit-ish of latchkey>            See `git describe --always`
```

##### REMINDER

###### INSTALL

```sh
sudo mkdir -p /home/{latch,stow} /usr/local/stow
sudo chown -R "${USER}:${USER}" /home/{latch,stow}
sudo chown -R root:staff /usr/local/stow
git clone "https://github.com/D630/latch" /home/latch
git clone --mirror "https://github.com/D630/latch-keys" /home/latch/var/ring/.git
cd /home/latch/var/ring
git config --local --bool core.bare false
git checkout master
cd /home/latch
git clone "https://github.com/D630/latch-config" etc
```

###### EXAMPLES

TODO

##### SONG OF THE REPO

[The Fall, Latch Key Kid](https://www.youtube.com/watch?v=hpPQqOblIys)

##### LICENCE

GNU GPLv3
