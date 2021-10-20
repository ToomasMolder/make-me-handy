# Make me handy

Make my Ubuntu working environment handy to use.
Distribute my settings and management scripts throughout my servers.

Note! It works on *my* server(s). Feel free to modify in a way it works on your server(s) as well.

## Download and prepare

Download, use Git or checkout with SVN using the web URL.

```bash
REPO="make-me-handy"
REPOSRC="https://github.com/ToomasMolder/${REPO}.git"
LOCALREPO="${HOME}/${REPO}"
# We do it this way so that we can abstract if from just git later on
LOCALREPO_VC_DIR=${LOCALREPO}/.git
if [ ! -d ${LOCALREPO_VC_DIR} ]
then
    cd ${HOME}
    git clone ${REPOSRC} ${LOCALREPO}
else
    cd ${LOCALREPO}
    git pull ${REPOSRC}
fi
# End
```

Ensure directories are visitable, files readable and scripts executable

```bash
find ${LOCALREPO} -type d -print0 | xargs --null chmod 755
find ${LOCALREPO} -type f -print0 | xargs --null chmod 644
find ${LOCALREPO} -type f -name "*.sh" -print0 | xargs --null chmod 755
```

Relocate scripts from repository into ${HOME}/bin

```bash
mkdir --parents ${HOME}/bin
/bin/cp --preserve ${LOCALREPO}/bin/* ${HOME}/bin
```

## Make my Ubuntu working environment handy

Make my environment handy, updates environment files 
- ${HOME}/.profile
- ${HOME}/.bashrc
- ${HOME}/.bash_aliases
- ${HOME}/.vimrc
- ${HOME}/.screenrc
- ${HOME}/.config/htop/htoprc

Run from command line:

```bash
${HOME}/bin/make_my.sh
```

## Distribute my settings and management scripts throughout my servers

Script distributes my own settings from one server to another using secure copy (`scp`).
Note! Script includes generation of public/private key pair and distribute public key as well (`ssh-copy-id`)

### Prepare bin/distribute.sh

Set up list of environment files to be distributed, sample:

```bash
DOTFILES="${HOME}/.profile ${HOME}/.bashrc ${HOME}/.bash_aliases ${HOME}/.vimrc ${HOME}/.screenrc"
HTOPRC="${HOME}/.config/htop/htoprc"
```

More to be added if you have and wish.

Set up list of management scripts to be distributed, sample:

```bash
BINFILES="${HOME}/bin/colours.sh ${HOME}/bin/highlight.sh ${HOME}/bin/update.sh"
```

More to be added if you have and wish.

Set up space-delimited list of my servers:

```bash
DESTINATIONS=""
```

Run from command line:

```bash
${HOME}/bin/distribute.sh
```

## Author

Toomas Mölder <toomas.molder+makemehandy@gmail.com>

## Contribute

Through pull requests or issues. Thank you!