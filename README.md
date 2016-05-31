##### README

I am on Debian GNU/Linux (testing/sid), and I use its software repository and package management system for installing the most part of my favourite utilities. Parallel to this, I build, install and "update" source packages coming from Git repositories, what is increasingly uncomfortable and produces the need of a way to manage this all. That is why I decided to write some simple shell scripts and to use them with git and [xstow](http://xstow.sourceforge.net/) as key tools.

You need a POSIX shell + "local" builtin command to make this business work properly.

##### USAGE

```
Subcommands
-----------
forge
    add                 Add a latchkey (Git branch) to the ring; create
                        a LINFO  file and a LBUILD template.
                        $1 := URI
                        $2 := BRANCH
                        ++ := CONTEXT
    commit              Update the index and store changes in new a
                        commit.
    remove              Destroy latchkey.
                        $1 := BRANCH
    ring                Initialize empty "latchkey ring"
                        (non-bare Git repository).

mr
    mirror              Mirror or update all configured remotes (bare Git
                        repositories).

pkg
    chop                Delete all installed stow packages, but the stowed one.
                        $1 := BRANCH
    init                Initialize empty stow package directory
                        (non-bare Git repository).
                        $1 := BRANCH
    install             Build and install a package version into a
                        stow package directory (via LBUILD file).
                        $1 := BRANCH
                        ++ := commit-ish of mirror
                        ++ := commit-ish of latchkey
    purge               Purge a stow package directory and all package
                        versions in it.
                        $1 := BRANCH
    remove              Remove/Delete a package version.
                        $1 := BRANCH
                        ++ := commit-ish of mirror
                        ++ := commit-ish of latchkey
    stow                Stow pkg into the target directory.
                        $1 := BRANCH
                        ++ := commit-ish of mirror
                        ++ := commit-ish of latchkey
    test                Show, how a pkg command would be configured.
                        $1 := BRANCH
                        ++ := commit-ish of mirror
                        ++ := commit-ish of latchkey
    unstow              Delete stowed pkg from the target directory.
                        $1 := BRANCH
                        ++ := commit-ish of mirror
                        ++ := commit-ish of latchkey
    unstow-curr         Alias for:
                        $1 := BRANCH
                        $2 := commit-ish of stowed mirror
                        $3 := commit-ish of stowed latchkey

rehash
                        Read LINFO from the master latchkey and record all
                        keys and mirror in the mirror.list file.

Arguments
---------
    BRANCH                              github.com/junegunn/fzf
    CONTEXT                             local | global | system
    URI                                 http://git.suckless.org/st
    commit-ish of stowed mirror         See `git describe --always`
    commit-ish of stowed latchkey       See `git describe --always`
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

##### SONG OF THE REPO

[The Fall, Latch Key Kid](https://www.youtube.com/watch?v=hpPQqOblIys)

##### LICENCE

GNU GPLv3
