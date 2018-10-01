#!/bin/bash

mkdir -p /usr/local/Git/GitHubSandbox/git
mkdir -p /usr/local/Git/GitHubSandbox/tom-weatherhead
cd /usr/local/Git/GitHubSandbox/git
git clone https://github.com/git/git.git
cd /usr/local/Git/GitHubSandbox/tom-weatherhead
git clone https://github.com/tom-weatherhead/bash-scripts.git
cd ~
mkdir Backup
mkdir bin
mv .profile Backup/
ln -sf /usr/local/Git/GitHubSandbox/git/git/contrib/completion/git-completion.bash
ln -sf /usr/local/Git/GitHubSandbox/git/git/contrib/completion/git-prompt.sh
ln -sf /usr/local/Git/GitHubSandbox/tom-weatherhead/bash-scripts/.bash_aliases
ln -sf /usr/local/Git/GitHubSandbox/tom-weatherhead/bash-scripts/.bash_profile
mv .bashrc Backup/
ln -sf /usr/local/Git/GitHubSandbox/tom-weatherhead/bash-scripts/.bashrc
cd bin
/usr/local/Git/GitHubSandbox/tom-weatherhead/bash-scripts/create_bash_script_links.sh

# See https://github.com/creationix/nvm for the current nvm version number.
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
