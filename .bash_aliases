# .bash_aliases - January 29, 2017
# See https://askubuntu.com/questions/17536/how-do-i-create-a-permanent-bash-alias
# alias cs='cd;ls'
alias lb='ls -al ~/.bash*'

#-------------------
# Personal Aliases
#-------------------

# Avoid accidentally clobbering files:
alias rm='rm -i'
alias cp='cp -i'
# alias mv='mv -i'

alias mkdir='mkdir -p'

alias h='history'
alias j='jobs -l'
alias which='type -a'
# alias ..='cd ..'

# Pretty-print of some PATH variables:
alias path='echo -e ${PATH//:/\\n}'
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'

alias du='du -kh'    # Makes a more readable output.
alias df='df -kTh'

#-------------------------------------------------------------
# The 'ls' family (this assumes you use a recent GNU ls).
#-------------------------------------------------------------
# Add colors for filetype and human-readable sizes by default on 'ls':
# alias ls='ls -h --color'
alias ls='ls -h'
alias lx='ls -lXB'         #  Sort by extension.
alias lk='ls -lSr'         #  Sort by size, biggest last.
alias lt='ls -ltr'         #  Sort by date, most recent last.
alias lc='ls -ltcr'        #  Sort by/show change time,most recent last.
alias lu='ls -ltur'        #  Sort by/show access time,most recent last.

# The ubiquitous 'll': directories first, with alphanumeric sorting:
alias ll="ls -lv --group-directories-first"
alias lm='ll | more'       #  Pipe through 'more'
alias lr='ll -R'           #  Recursive ls.
alias la='ll -A'           #  Show hidden files.
alias tree='tree -Csuh'    #  Nice alternative to 'recursive ls' ...

#-------------------------------------------------------------
# Spelling typos - highly personnal and keyboard-dependent :-)
#-------------------------------------------------------------
alias xs='cd'
alias vf='cd'
alias moer='more'
alias moew='more'
alias kk='ll'

# Aliases that use xtitle
alias top='xtitle Processes on $HOST && top'
alias make='xtitle Making $(basename $PWD) ; make'

# ****

# From Xavier Damman's .profile : See https://gist.github.com/xdamman/eefcc3a28231b5154e3d

alias reload="source ~/.profile"

# git Aliases
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m' # requires you to type a commit message
alias gp='git push'
alias gco="git commit -am"
alias glog='git log --date-order --all --graph --format="%C(green)%h%Creset %C(yellow)%an%Creset %C(blue bold)%ar%Creset %C(red bold)%d %Creset%s"'
# eval "$(hub alias -s)" # Wrap git with hub https://github.com/github/hub

# usage
alias battery='upower -i $(upower -e | grep 'BAT') | grep -E "state|to\ full|percentage|time\ to\ empty"'
alias top-cpu='ps -eo pcpu,pid,user,command | sort -k 1 -r | head -n 11 | sed -e "s/^\(.\{`tput cols`\}\).*/\1/g"'
alias top-memory='ps -eo %mem,rss,pid,user,cmd | sort -k 1,2 -r | head -n 11 | sed -e "s/^\(.\{180\}\).*/\1/g"'

# Put the screen to sleep (which also locks the computer)
alias lock="pmset displaysleepnow"

# Customizing the prompt to show "username:cwd (git-branch)>" with some colors
#function currentBranch {
#  branch=$(git branch 2>/dev/null | grep "*" | sed -E "s/\* //") || return
#  if [ -n "$branch" ]; then
#    echo -e "(\[\e\033[36m\]"$branch"\[\e\033[m\])"
#  fi
#}
#export PS1="\u\[\e\033[0;96m\]:\w\[\e\033[m\] "$(currentBranch)"> " # prompt

# up 'n' folders
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Simple ip
# ThAW 2017/07/04: "ip" is now a Linux command, similar to "ifconfig"; e.g. "ip a"
alias ipa='ifconfig | grep "inet " | grep -v 127.0.0.1 | sed -E "s/[^0-9]*([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}).*/\1/"'
alias localip=ipa

# external ip
# alias ip-external='curl http://wtfismyip.com/text'
# alias externalip=ip-external

# grep with color
alias grep='grep --color=auto'

# pretty json in color (`sudo npm install -g json`)
# alias json="json -i"

### Aliases

# Open specified files in Sublime Text
# "s ." will open the current directory in Sublime
# alias s='open -a "Sublime Text"'

# Color LS
colorflag="-G"
# alias ls="command ls ${colorflag}"
# alias ll="ls -l ${colorflag}"
# alias l="ls -lF ${colorflag}" # all files, in long format
# alias la="ls -laF ${colorflag}" # all files inc dotfiles, in long format
# alias lsd='ls -lF ${colorflag} | grep "^d"' # only directories

# Enable aliases to be sudo’ed
alias sudo='sudo '

# Colored up cat!
# You must install Pygments first - "sudo easy_install Pygments"
#alias c='pygmentize -O style=monokai -f console256 -g'

# ThAW's Additional Aliases

# Git aliases: Begin

# gbz : Create a bzip2-compressed archive of a Git repository.
alias gbz='[ -d .git ] && { git archive --format=tar HEAD | bzip2 -9 - > "../$(basename $(pwd))_$(date --utc +%Y-%m-%d_%H-%M-%S).tar.bz2"; } || { echo "No .git subdirectory detected."; }'

# Create the "gh" ("GitHub") alias.
alias gh='cd $(archive_dir_parent); cd Archive/Git/GitHubSandbox/tom-weatherhead 1>&/dev/null'
alias lg='cd $(archive_dir_parent); cd Archive/Git/LocalSandbox 1>&/dev/null'
alias n='cd $(archive_dir_parent); cd Archive/Git/LocalSandbox/Node.js 1>&/dev/null'
alias m='cd $(archive_dir_parent); cd Archive/Git/LocalSandbox/Node.js/Express.js/MEAN 1>&/dev/null'
alias mern='cd $(archive_dir_parent); cd Archive/Git/LocalSandbox/Node.js/Express.js/MERN 1>&/dev/null'

# Git aliases: End

alias fnm='find . -type d -name node_modules'
# TODO? : Create an alias that auto-removes all node_modules directories? Or just exclude them from the archive that tar creates?

# find -exec : See e.g. https://linuxaria.com/howto/linux-shell-how-to-use-the-exec-option-in-find-with-examples

# Purge node_modules
# alias pnm='find . -type d -name node_modules -exec rm -rf {} \;'
alias pnm='find . -type d -name node_modules -exec rm -rf {} \; -prune'
# alias pnm='find . -type d -name node_modules -delete'

# Purge log files
alias plg='find . -type f -iname "*.log" -exec rm -f {} \;'

alias pipe_status='echo "${PIPESTATUS[@]}" | tr -s " " + | bc'
alias arch_bits='uname -m | sed "s/x86_//;s/i[3-6]86/32/"'

alias shhi="history | awk '{a[\$4]++ } END{for(i in a){print a[i], i}}' | sort -rn | head"

# sed:
# - s : Regular-expression-based substitution : s/regexp/replacement/

# Django aliases: Begin

alias djrun='./manage.py runserver 0:8000'

# Django aliases: End

alias cleansrt="sed 's/\r//;s/<br>/\n/'|perl -00pe's/.*@.*//s'|perl -00pe's/^.*$/\Q$.\E/m'"

# End of .bash_aliases
