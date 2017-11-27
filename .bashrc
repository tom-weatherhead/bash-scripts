# See http://tldp.org/LDP/abs/html/sample-bashrc.html

if [[ ! $- == *i* ]]; then
    . /etc/profile
fi

# ThAW 2017/08/20 : Some setup of the Bash environment needs to be done regardless of whether we're running interactively or not, so do it now, before the '[ -z "$PS1" ] && return'

# Do not echo anything before the '[ -z "$PS1" ] && return', because a .bashrc that echoes anything will break scp.

HOME_BIN_DIR="$HOME/bin"

function use_home_bin()
{
	if ! [ -e "$HOME_BIN_DIR" ]; then
		# echo "$HOME_BIN_DIR does not exist."
		return
	elif ! [ -d "$HOME_BIN_DIR" ]; then
		# echo "$HOME_BIN_DIR is not a directory."
		return
	elif ! [ -r "$HOME_BIN_DIR" ]; then
		# echo "$HOME_BIN_DIR is not readable."
		return
	# elif echo $PATH | grep $HOME_BIN_DIR; then
	elif [[ $PATH =~ $HOME_BIN_DIR ]]; then
		# echo "$HOME_BIN_DIR is already in the path."
		return
	else
		# echo "Adding $HOME_BIN_DIR to the path."
		PATH="$HOME_BIN_DIR:$PATH"
		# export PATH
	fi
}

use_home_bin

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

#--------------------------------------------------------------
#  Automatic setting of $DISPLAY (if not set already).
#  The problem is that different types of terminals give
#+ different answers to 'who am i' (rxvt in particular can be
#+ troublesome) - however this code seems to work in a majority
#+ of cases.
#--------------------------------------------------------------

function get_xserver ()
{
	case $TERM in
		xterm)
			XSERVER=$(who am i | awk '{print $NF}' | tr -d ')''(' )
			# Ane-Pieter Wieringa suggests the following alternative:
			#  I_AM=$(who am i)
			#  SERVER=${I_AM#*(}
			#  SERVER=${SERVER%*)}
			XSERVER=${XSERVER%%:*}
			;;
		aterm | rxvt)
			# Find some code that works here. ...
			;;
	esac
}

if [ -z ${DISPLAY:=""} ]; then
    get_xserver
    if [[ -z ${XSERVER} || ${XSERVER} == $(hostname) || ${XSERVER} == "unix" ]]; then
		DISPLAY=":0.0"				# Display on local host.
    else
		DISPLAY=${XSERVER}:0.0		# Display on remote host.
    fi
fi

export DISPLAY

#set -o nounset     # These  two options are useful for debugging.
#set -o xtrace
alias debug="set -o nounset; set -o xtrace"

ulimit -S -c 0      # Don't want coredumps.
set -o notify
set -o noclobber
set -o ignoreeof

# Enable options:
shopt -s cdspell
shopt -s cdable_vars
shopt -s checkhash
shopt -s checkwinsize
shopt -s sourcepath
shopt -s no_empty_cmd_completion
shopt -s cmdhist
shopt -s histappend histreedit histverify
shopt -s extglob       # Necessary for programmable completion.

# Disable options:
shopt -u mailwarn
unset MAILCHECK        # Don't want my shell to warn me of incoming mail.

# Color definitions (taken from Color Bash Prompt HowTo).
# Some colors might look different of some terminals.
# For example, I see 'Bold Red' as 'orange' on my screen,
# hence the 'Green' 'BRed' 'Red' sequence I often use in my prompt.

# Normal Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

# Bold
BBlack='\e[1;30m'       # Black
BRed='\e[1;31m'         # Red
BGreen='\e[1;32m'       # Green
BYellow='\e[1;33m'      # Yellow
BBlue='\e[1;34m'        # Blue
BPurple='\e[1;35m'      # Purple
BCyan='\e[1;36m'        # Cyan
BWhite='\e[1;37m'       # White

# Background
On_Black='\e[40m'       # Black
On_Red='\e[41m'         # Red
On_Green='\e[42m'       # Green
On_Yellow='\e[43m'      # Yellow
On_Blue='\e[44m'        # Blue
On_Purple='\e[45m'      # Purple
On_Cyan='\e[46m'        # Cyan
On_White='\e[47m'       # White

NC="\e[m"               # Color Reset

ALERT=${BWhite}${On_Red} # Bold White on red background

function _exit()              # Function to run upon exit of shell.
{
    echo -e "${Cyan}God loves you!${NC}"
}

trap _exit EXIT

#-------------------------------------------------------------
# Shell Prompt - for many examples, see:
#       http://www.debian-administration.org/articles/205
#       http://www.askapache.com/linux/bash-power-prompt.html
#       http://tldp.org/HOWTO/Bash-Prompt-HOWTO
#       https://github.com/nojhan/liquidprompt
#-------------------------------------------------------------
# Current Format: [TIME USER@HOST PWD] >
# TIME:
#    Green     == machine load is low
#    Orange    == machine load is medium
#    Red       == machine load is high
#    ALERT     == machine load is very high
# USER:
#    Cyan      == normal user
#    Orange    == SU to user
#    Red       == root
# HOST:
#    Cyan      == local session
#    Green     == secured remote connection (via ssh)
#    Red       == unsecured remote connection
# PWD:
#    Green     == more than 10% free disk space
#    Orange    == less than 10% free disk space
#    ALERT     == less than 5% free disk space
#    Red       == current user does not have write privileges
#    Cyan      == current filesystem is size zero (like /proc)
# >:
#    White     == no background or suspended jobs in this shell
#    Cyan      == at least one background job in this shell
#    Orange    == at least one suspended job in this shell
#
#    Command is added to the history file each time you hit enter,
#    so it's available to all shells (using 'history -a').

# Test connection type:
if [ -n "${SSH_CONNECTION}" ]; then
    CNX=${Green}        # Connected on remote machine, via ssh (good).
elif [[ "${DISPLAY%%:0*}" != "" ]]; then
    CNX=${ALERT}        # Connected on remote machine, not via ssh (bad).
else
    CNX=${BCyan}        # Connected on local machine.
fi

# Test user type:
if [[ ${USER} == "root" ]]; then
    SU=${Red}           # User is root.
# elif [[ ${USER} != $(logname) ]]; then	# TW 2017/01/20 : In Windows 10 Bash, logname prints "logname: no login name"
elif [[ ${USER} != $(whoami) ]]; then		# TW 2017/01/20 : Replaced logname with whoami.
    SU=${BRed}          # User is not login user.
else
    SU=${BCyan}         # User is normal.
fi

NCPU=$(grep -c 'processor' /proc/cpuinfo)	# Number of CPUs
SLOAD=$(( 100*${NCPU} ))					# Small load
MLOAD=$(( 200*${NCPU} ))					# Medium load
XLOAD=$(( 400*${NCPU} ))					# Xlarge load

# Returns system load as percentage, i.e., '40' rather than '0.40)'.
function load()
{
    local SYSLOAD=$(cut -d " " -f1 /proc/loadavg | tr -d '.')
    # System load of the current host.
    echo $((10#$SYSLOAD))       # Convert to decimal.
}

# Returns a color indicating system load.
function load_color()
{
    local SYSLOAD=$(load)
    if [ ${SYSLOAD} -gt ${XLOAD} ]; then
        echo -en ${ALERT}
    elif [ ${SYSLOAD} -gt ${MLOAD} ]; then
        echo -en ${Red}
    elif [ ${SYSLOAD} -gt ${SLOAD} ]; then
        echo -en ${BRed}
    else
        echo -en ${Green}
    fi
}

# Returns a color according to free disk space in $PWD.
function disk_color()
{
    if [ ! -w "${PWD}" ] ; then
        echo -en ${Red}
        # No 'write' privilege in the current directory.
    elif [ -s "${PWD}" ] ; then
        local used=$(command df -P "$PWD" | awk 'END {print $5} {sub(/%/,"")}')
        if [ ${used} -gt 95 ]; then
            echo -en ${ALERT}           # Disk almost full (>95%).
        elif [ ${used} -gt 90 ]; then
            echo -en ${BRed}            # Free disk space almost gone.
        else
            echo -en ${Green}           # Free disk space is ok.
        fi
    else
        echo -en ${Cyan}
        # Current directory is size '0' (like /proc, /sys etc).
    fi
}

# Returns a color according to running/suspended jobs.
function job_color()
{
    if [ $(jobs -s | wc -l) -gt "0" ]; then
        echo -en ${BRed}
    elif [ $(jobs -r | wc -l) -gt "0" ] ; then
        echo -en ${BCyan}
	else
        # echo -en ${BWhite}
        echo -en ${BGreen}
    fi
}

parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

if [ -f ~/git-completion.bash ]; then
	source ~/git-completion.bash
fi

# Now we construct the prompt.

PROMPT_COMMAND="history -a"
case ${TERM} in
#	*term | rxvt | linux)
	*term | xterm-256color | rxvt)
		# ThAW 2017/04/04 : Can we add "$(arch_bits)-bit " into the prompt somewhere? (So we don't confuse 32-bit and 64-bit Cygwin Terminals)
        # PS1="\[\$(load_color)\][\A\[${NC}\] "
        # Time of day (with load info):
        PS1="\[\$(load_color)\][\A\[${NC}\] "
        # User@Host (with connection type info):
        PS1=${PS1}"\[${SU}\]\u\[${NC}\]@\[${CNX}\]\h\[${NC}\] "

        # PWD (with 'disk space' info):
        # PS1=${PS1}"\[\$(disk_color)\]\W]\[${NC}\] "
        # PS1=${PS1}"\[\$(disk_color)\]\W\[\033[32m\]]\[${NC}\]"			# Same as the line above, but with the trailing space removed.

		# \w yields the full directory path; \W yields just the name of the topmost directory (the last directory name in the full directory path).
        PS1=${PS1}"\[\$(disk_color)\]\W\[\$(load_color)\]]\[${NC}\]"		# Ensure that the closing ] is coloured with $(load_color) , just like the opening [ .
        # PS1=${PS1}"\[\$(disk_color)\]\w\[\$(load_color)\]]\[${NC}\]"		# Ensure that the closing ] is coloured with $(load_color) , just like the opening [ .

        # Prompt (with 'job' info):
        # PS1=${PS1}"\[\$(job_color)\]>\[${NC}\] "

		# See https://coderwall.com/p/fasnya/add-git-branch-name-to-bash-prompt :

		# export PS1="\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "

		# See https://git-scm.com/book/uz/v2/Git-in-Other-Environments-Git-in-Bash :

		# $ mkdir -p ~/Archive/Git/GitHubSandbox/git
		# $ cd ~/Archive/Git/GitHubSandbox/git
		# $ git clone https://github.com/git/git.git
		# $ cd ~
		# $ ln -sf Archive/Git/GitHubSandbox/git/git/contrib/completion/git-completion.bash
		# $ ln -sf Archive/Git/GitHubSandbox/git/git/contrib/completion/git-prompt.sh

		if [ -f ~/git-prompt.sh ]; then
			source ~/git-prompt.sh
			GIT_PS1_SHOWDIRTYSTATE=1
			GIT_BRANCH_INFO='$(__git_ps1 " (%s)")'
			# PS1='\w$(__git_ps1 " (%s)")\$ '						# Yes! Because: No colours.
			# PS1=${PS1}${Purple}'\w$(__git_ps1 " (%s)") \$ '		# No.
			# PS1=${PS1}'\w$(__git_ps1 " (%s)") \$ '
			# PS1=${PS1}"${Purple}${GIT_FOO}${Cyan}\$ ${White}"
			# PS1=${PS1}"\e[0;35m${GIT_FOO}"
		else
			# export PS1="\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "

			# PS1=${PS1}"${Purple}\$(parse_git_branch) ${Cyan}\$ ${White}"
			# PS1=${PS1}"\[\033[35m\]$(parse_git_branch) \[\033[36m\]\$ \[\033[37m\]"

			GIT_BRANCH_INFO=" $(parse_git_branch)"
		fi

		# PS1=${PS1}"${Purple}${GIT_BRANCH_INFO} ${Cyan}\$ ${White}"
		# PS1=${PS1}"\[\033[35m\]${GIT_BRANCH_INFO} \[\033[36m\]\$ \[\033[37m\]"
		PS1=${PS1}"\[\033[35m\]${GIT_BRANCH_INFO} "

		# \[\033[32m\] is Green.
		# \[\033[33m\] is Yellow.
		# \[\033[34m\] is Blue.
		# PS1=${PS1}"\[\033[32m\]Green "

        # Prompt (with 'job' info):
        PS1=${PS1}"\[\$(job_color)\]>\[${NC}\] "

        # Set title of current xterm:
        PS1=${PS1}"\[\e]0;[\u@\h] \w\a\]"
        ;;
    *)
        PS1="(\A \u@\h \W) > " # --> PS1="(\A \u@\h \w) > "
                               # --> Shows full pathname of current dir.
        ;;
esac

export TIMEFORMAT=$'\nreal %3R\tuser %3U\tsys %3S\tpcpu %P\n'
export HISTIGNORE="&:bg:fg:ll:h"
export HISTTIMEFORMAT="$(echo -e ${BCyan})[%d/%m %H:%M:%S]$(echo -e ${NC}) "
export HISTCONTROL=ignoredups
export HOSTFILE=$HOME/.hosts    # Put a list of remote hosts in ~/.hosts

#============================================================
#
#  FUNCTIONS
#
#  Arguably, some functions defined here are quite big.
#  If you want to make this file smaller, these functions can
#  be converted into scripts and removed from here.
#
#============================================================

#-------------------------------------------------------------
# Tailoring 'less'
#-------------------------------------------------------------

# alias more='less'
# export PAGER=less
# export LESSCHARSET='latin1'
# export LESSOPEN='|/usr/bin/lesspipe.sh %s 2>&-'
                # Use this if lesspipe.sh exists.
# export LESS='-i -N -w  -z-4 -g -e -M -X -F -R -P%t?f%f \
# :stdin .?pb%pb\%:?lbLine %lb:?bbByte %bb:-...'

# LESS man page colors (makes Man pages more readable).
# export LESS_TERMCAP_mb=$'\E[01;31m'
# export LESS_TERMCAP_md=$'\E[01;31m'
# export LESS_TERMCAP_me=$'\E[0m'
# export LESS_TERMCAP_se=$'\E[0m'
# export LESS_TERMCAP_so=$'\E[01;44;33m'
# export LESS_TERMCAP_ue=$'\E[0m'
# export LESS_TERMCAP_us=$'\E[01;32m'

#-------------------------------------------------------------
# A few fun ones
#-------------------------------------------------------------

# Adds some text in the terminal frame (if applicable).

function xtitle()
{
    case "$TERM" in
		*term* | rxvt)
			echo -en  "\e]0;$*\a"
			;;
		*)
			;;
    esac
}

#-------------------------------------------------------------
# Make the following commands run in background automatically:
#-------------------------------------------------------------

# function te()  # wrapper around xemacs/gnuserv
# {
#   if [ "$(gnuclient -batch -eval t 2>&-)" == "t" ]; then
#       gnuclient -q "$@";
#    else
#       ( xemacs "$@" &);
#    fi
# }

# function soffice() { command soffice "$@" & }
# function firefox() { command firefox "$@" & }
# function xpdf() { command xpdf "$@" & }

#-------------------------------------------------------------
# File- and string-related functions
#-------------------------------------------------------------

# Find a file with a pattern in name:
function ff() { find . -type f -iname '*'"$*"'*' -ls ; }

# Find a file with pattern $1 in name and Execute $2 on it:
function fe() { find . -type f -iname '*'"${1:-}"'*' -exec ${2:-file} {} \;  ; }

#  Find a pattern in a set of files and highlight them:
#  (needs a recent version of egrep).
function fstr()
{
    OPTIND=1
    local mycase=""
    local usage="fstr: find string in files.
Usage: fstr [-i] \"pattern\" [\"filename pattern\"] "
    while getopts :it opt
    do
        case "$opt" in
           i) mycase="-i " ;;
           *) echo "$usage"; return ;;
        esac
    done
    shift $(( $OPTIND - 1 ))
    if [ "$#" -lt 1 ]; then
        echo "$usage"
        return;
    fi
    find . -type f -name "${2:-*}" -print0 | xargs -0 egrep --color=always -sn ${case} "$1" 2>&- | more
}

function swap()
# Swap 2 filenames around, if they exist. (from Uzi's bashrc).
{
    local TMPFILE=tmp.$$

    [ $# -ne 2 ] && echo "swap: 2 arguments needed" && return 1
    [ ! -e $1 ] && echo "swap: $1 does not exist" && return 1
    [ ! -e $2 ] && echo "swap: $2 does not exist" && return 1

    mv "$1" $TMPFILE
    mv "$2" "$1"
    mv $TMPFILE "$2"
}

function extract()      # Handy Extract Program
{
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xvjf $1     ;;
            *.tar.gz)    tar xvzf $1     ;;
            *.bz2)       bunzip2 $1      ;;
            *.rar)       unrar x $1      ;;
            *.gz)        gunzip $1       ;;
            *.tar)       tar xvf $1      ;;
            *.tbz2)      tar xvjf $1     ;;
            *.tgz)       tar xvzf $1     ;;
            *.zip)       unzip $1        ;;
            *.Z)         uncompress $1   ;;
            *.7z)        7z x $1         ;;
            *)           echo "'$1' cannot be extracted via >extract<" ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}

# Creates an archive (*.tar.gz) from given directory.
function maketar() { tar cvzf "${1%%/}.tar.gz"  "${1%%/}/"; }

# Create a ZIP archive of a file or folder.
function makezip() { zip -r "${1%%/}.zip" "$1" ; }

# Make your directories' and files' access rights sane.
function sanitize() { chmod -R u=rwX,g=rX,o= "$@" ;}

#-------------------------------------------------------------
# Process/system related functions:
#-------------------------------------------------------------

function my_ps() { ps $@ -u $USER -o pid,%cpu,%mem,bsdtime,command ; }
function pp() { my_ps f | awk '!/awk/ && $0~var' var=${1:-".*"} ; }

function killps()   # kill by process name
{
    local pid pname sig="-TERM"   # default signal
    if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
        echo "Usage: killps [-SIGNAL] pattern"
        return;
    fi
    if [ $# = 2 ]; then sig=$1 ; fi
    for pid in $(my_ps| awk '!/awk/ && $0~pat { print $1 }' pat=${!#} )
    do
        pname=$(my_ps | awk '$1~var { print $5 }' var=$pid )
        if ask "Kill process $pid <$pname> with signal $sig?"
            then kill $sig $pid
        fi
    done
}

function mydf()         # Pretty-print of 'df' output.
{                       # Inspired by 'dfc' utility.
    for fs ; do

        if [ ! -d $fs ]
        then
          echo -e $fs" :No such file or directory" ; continue
        fi

        local info=( $(command df -P $fs | awk 'END{ print $2,$3,$5 }') )
        local free=( $(command df -Pkh $fs | awk 'END{ print $4 }') )
        local nbstars=$(( 20 * ${info[1]} / ${info[0]} ))
        local out="["
        for ((j=0;j<20;j++)); do
            if [ ${j} -lt ${nbstars} ]; then
               out=$out"*"
            else
               out=$out"-"
            fi
        done
        out=${info[2]}" "$out"] ("$free" free on "$fs")"
        echo -e $out
    done
}

function my_ip() # Get IP adress on ethernet.
{
    MY_IP=$(/sbin/ifconfig eth0 | awk '/inet/ { print $2 } ' |
      sed -e s/addr://)
    echo ${MY_IP:-"Not connected"}
}

function ii()   # Get current host related info.
{
    echo -e "\nYou are logged on ${BRed}$HOST"
    echo -e "\n${BRed}Additionnal information:$NC " ; uname -a
    echo -e "\n${BRed}Users logged on:$NC " ; w -hs |
             cut -d " " -f1 | sort | uniq
    echo -e "\n${BRed}Current date :$NC " ; date
    echo -e "\n${BRed}Machine stats :$NC " ; uptime
    echo -e "\n${BRed}Memory stats :$NC " ; free
    echo -e "\n${BRed}Diskspace :$NC " ; mydf / $HOME
    # echo -e "\n${BRed}Local IP Address :$NC" ; my_ip
    # echo -e "\n${BRed}Open connections :$NC "; netstat -pan --inet;
    echo
}

#-------------------------------------------------------------
# Misc utilities:
#-------------------------------------------------------------

function repeat()       # Repeat n times command.
{
    local i max
    max=$1; shift;
    for ((i=1; i <= max ; i++)); do  # --> C-like syntax
        eval "$@";
    done
}

function ask()          # See 'killps' for example of use.
{
    echo -n "$@" '[y/n] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}

function corename()   # Get name of app that created a corefile.
{
    for file ; do
        echo -n $file : ; gdb --core=$file --batch | head -1
    done
}

#=========================================================================
#  PROGRAMMABLE COMPLETION SECTION
#  Most are taken from the bash 2.05 documentation and from Ian McDonald's
# 'Bash completion' package (http://www.caliban.org/bash/#completion)
#  You will in fact need bash more recent then 3.0 for some features.
#
#  Note that most linux distributions now provide many completions
# 'out of the box' - however, you might need to make your own one day,
#  so I kept those here as examples.
#=========================================================================

if [ "${BASH_VERSION%.*}" \< "3.0" ]; then
    echo "You will need to upgrade to version 3.0 for full programmable completion features"
    return
fi

shopt -s extglob        # Necessary.

complete -A hostname   rsh rcp telnet rlogin ftp ping disk
complete -A export     printenv
complete -A variable   export local readonly unset
complete -A enabled    builtin
complete -A alias      alias unalias
complete -A function   function
complete -A user       su mail finger

complete -A helptopic  help     # Currently same as builtins.
complete -A shopt      shopt
complete -A stopped -P '%' bg
complete -A job -P '%'     fg jobs disown

complete -A directory  mkdir rmdir
complete -A directory   -o default cd

# Compression
complete -f -o default -X '*.+(zip|ZIP)'  zip
complete -f -o default -X '!*.+(zip|ZIP)' unzip
complete -f -o default -X '*.+(z|Z)'      compress
complete -f -o default -X '!*.+(z|Z)'     uncompress
complete -f -o default -X '*.+(gz|GZ)'    gzip
complete -f -o default -X '!*.+(gz|GZ)'   gunzip
complete -f -o default -X '*.+(bz2|BZ2)'  bzip2
complete -f -o default -X '!*.+(bz2|BZ2)' bunzip2
complete -f -o default -X '!*.+(zip|ZIP|z|Z|gz|GZ|bz2|BZ2)' extract

# Documents - Postscript,pdf,dvi.....
complete -f -o default -X '!*.+(ps|PS)'  gs ghostview ps2pdf ps2ascii
complete -f -o default -X \
'!*.+(dvi|DVI)' dvips dvipdf xdvi dviselect dvitype
complete -f -o default -X '!*.+(pdf|PDF)' acroread pdf2ps
complete -f -o default -X '!*.@(@(?(e)ps|?(E)PS|pdf|PDF)?\
(.gz|.GZ|.bz2|.BZ2|.Z))' gv ggv
complete -f -o default -X '!*.texi*' makeinfo texi2dvi texi2html texi2pdf
complete -f -o default -X '!*.tex' tex latex slitex
complete -f -o default -X '!*.lyx' lyx
complete -f -o default -X '!*.+(htm*|HTM*)' lynx html2ps
complete -f -o default -X \
'!*.+(doc|DOC|xls|XLS|ppt|PPT|sx?|SX?|csv|CSV|od?|OD?|ott|OTT)' soffice

# Multimedia
complete -f -o default -X \
'!*.+(gif|GIF|jp*g|JP*G|bmp|BMP|xpm|XPM|png|PNG)' xv gimp ee gqview
complete -f -o default -X '!*.+(mp3|MP3)' mpg123 mpg321
complete -f -o default -X '!*.+(ogg|OGG)' ogg123
complete -f -o default -X \
'!*.@(mp[23]|MP[23]|ogg|OGG|wav|WAV|pls|\
m3u|xm|mod|s[3t]m|it|mtm|ult|flac)' xmms
complete -f -o default -X '!*.@(mp?(e)g|MP?(E)G|wma|avi|AVI|\
asf|vob|VOB|bin|dat|vcd|ps|pes|fli|viv|rm|ram|yuv|mov|MOV|qt|\
QT|wmv|mp3|MP3|ogg|OGG|ogm|OGM|mp4|MP4|wav|WAV|asx|ASX)' xine

complete -f -o default -X '!*.pl'  perl perl5

#  This is a 'universal' completion function - it works when commands have
#+ a so-called 'long options' mode , ie: 'ls --all' instead of 'ls -a'
#  Needs the '-o' option of grep
#+ (try the commented-out version if not available).

#  First, remove '=' from completion word separators
#+ (this will allow completions like 'ls --color=auto' to work correctly).

COMP_WORDBREAKS=${COMP_WORDBREAKS/=/}

_get_longopts()
{
	#$1 --help | sed  -e '/--/!d' -e 's/.*--\([^[:space:].,]*\).*/--\1/'| \
	#grep ^"$2" |sort -u ;
	$1 --help | grep -o -e "--[^[:space:].,]*" | grep -e "$2" |sort -u
}

_longopts()
{
    local cur
    cur=${COMP_WORDS[COMP_CWORD]}

    case "${cur:-*}" in
       -*)      ;;
        *)      return ;;
    esac

    case "$1" in
       \~*)     eval cmd="$1" ;;
         *)     cmd="$1" ;;
    esac
    COMPREPLY=( $(_get_longopts ${1} ${cur} ) )
}

complete  -o default -F _longopts configure bash
complete  -o default -F _longopts wget id info a2ps ls recode

_tar()
{
    local cur ext regex tar untar

    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}

    # If we want an option, return the possible long options.
    case "$cur" in
        -*)     COMPREPLY=( $(_get_longopts $1 $cur ) ); return 0;;
    esac

    if [ $COMP_CWORD -eq 1 ]; then
        COMPREPLY=( $( compgen -W 'c t x u r d A' -- $cur ) )
        return 0
    fi

    case "${COMP_WORDS[1]}" in
        ?(-)c*f)
            COMPREPLY=( $( compgen -f $cur ) )
            return 0
            ;;
        +([^Izjy])f)
            ext='tar'
            regex=$ext
            ;;
        *z*f)
            ext='tar.gz'
            regex='t\(ar\.\)\(gz\|Z\)'
            ;;
        *[Ijy]*f)
            ext='t?(ar.)bz?(2)'
            regex='t\(ar\.\)bz2\?'
            ;;
        *)
            COMPREPLY=( $( compgen -f $cur ) )
            return 0
            ;;

    esac

    if [[ "$COMP_LINE" == tar*.$ext' '* ]]; then
        # Complete on files in tar file.
        #
        # Get name of tar file from command line.
        tar=$( echo "$COMP_LINE" | \
                        sed -e 's|^.* \([^ ]*'$regex'\) .*$|\1|' )
        # Devise how to untar and list it.
        untar=t${COMP_WORDS[1]//[^Izjyf]/}

        COMPREPLY=( $( compgen -W "$( echo $( tar $untar $tar \
                                2>/dev/null ) )" -- "$cur" ) )
        return 0

    else
        # File completion on relevant files.
        COMPREPLY=( $( compgen -G $cur\*.$ext ) )

    fi

    return 0

}

complete -F _tar -o default tar

_make()
{
    local mdef makef makef_dir="." makef_inc gcmd cur prev i;
    COMPREPLY=();
    cur=${COMP_WORDS[COMP_CWORD]};
    prev=${COMP_WORDS[COMP_CWORD-1]};
    case "$prev" in
        -*f)
            COMPREPLY=($(compgen -f $cur ));
            return 0
            ;;
    esac;
    case "$cur" in
        -*)
            COMPREPLY=($(_get_longopts $1 $cur ));
            return 0
            ;;
    esac;

    # ... make reads
    #          GNUmakefile,
    #     then makefile
    #     then Makefile ...
    if [ -f ${makef_dir}/GNUmakefile ]; then
        makef=${makef_dir}/GNUmakefile
    elif [ -f ${makef_dir}/makefile ]; then
        makef=${makef_dir}/makefile
    elif [ -f ${makef_dir}/Makefile ]; then
        makef=${makef_dir}/Makefile
    else
       makef=${makef_dir}/*.mk         # Local convention.
    fi

    #  Before we scan for targets, see if a Makefile name was
    #+ specified with -f.
    for (( i=0; i < ${#COMP_WORDS[@]}; i++ )); do
        if [[ ${COMP_WORDS[i]} == -f ]]; then
            # eval for tilde expansion
            eval makef=${COMP_WORDS[i+1]}
            break
        fi
    done
    [ ! -f $makef ] && return 0

    # Deal with included Makefiles.
    makef_inc=$( grep -E '^-?include' $makef |
                 sed -e "s,^.* ,"$makef_dir"/," )
    for file in $makef_inc; do
        [ -f $file ] && makef="$makef $file"
    done


    #  If we have a partial word to complete, restrict completions
    #+ to matches of that word.
    if [ -n "$cur" ]; then gcmd='grep "^$cur"' ; else gcmd=cat ; fi

    COMPREPLY=( $( awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$)/ \
                               {split($1,A,/ /);for(i in A)print A[i]}' \
                                $makef 2>/dev/null | eval $gcmd  ))

}

complete -F _make -X '+($*|*.[cho])' make gmake pmake

_killall()
{
    local cur prev
    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}

    #  Get a list of processes
    #+ (the first sed evaluation
    #+ takes care of swapped out processes, the second
    #+ takes care of getting the basename of the process).
    COMPREPLY=( $( ps -u $USER -o comm  | \
        sed -e '1,1d' -e 's#[]\[]##g' -e 's#^.*/##'| \
        awk '{if ($0 ~ /^'$cur'/) print $0}' ))

    return 0
}

complete -F _killall killall killps

# **** Begin additions by TW ****

SUCCESS=0
FAILURE=1

which_test_quiet()
{
	which $1 >/dev/null 2>&1
	return $?
}

safe_eval()
{
	# echo "safe_eval: \$1 is '$1'"
	# echo "safe_eval: \$2 is '$2'"

	if [ -z "$2" ]; then
		CMD=$(echo $1 | awk '{print $1}')
	else
		CMD="$2"
	fi

	# which_test_quiet "$CMD" && echo "which_test_quiet '$CMD' : Yes" || echo "which_test_quiet '$CMD' : No"
	which_test_quiet "$CMD" && eval "$1"
}

is_a_non_negative_integer()
{
	# [[ "$1" =~ ^[0-9]+$ ]] && echo 1 || echo
	[[ "$1" =~ ^[0-9]+$ ]] && return $SUCCESS || return $FAILURE
}

archive_dir_parent()
{
	local A="/mnt/c"
	local B="/cygdrive/c"
	local C="$HOME"

	if [ -d "$A" ]; then
		echo "$A"
	elif [ -d "$B" ]; then
		echo "$B"
	elif [ -d "$C" ]; then
		echo "$C"
	else
		echo "archive_dir_parent() : Could not find $A, $B, or $C"
	fi
}

git_dir()
{
    local A="/usr/local/Git"
    local B="$(archive_dir_parent)/Archive/Git"

    # echo $A
    # echo $B

    if [ -d "$A" ]; then
        echo "$A"
    elif [ -d "$B" ]; then
        echo "$B"
    else
        echo "git_dir() : Could not find $A or $B"
    fi
}

# See https://stackoverflow.com/questions/14132210/use-find-command-but-exclude-files-in-two-directories
# find . -type f -name "*_peaks.bed" ! -path "./tmp/*" ! -path "./scripts/*"

# find in a Git / npm repository:

fgn()
{
	# find . -type f -iname "$1" ! -path "./.git/*" ! -path "./node_modules/*"
	find . -iname "$1" ! -path "./.git/*" ! -path "./node_modules/*"
}

# tar and bzip2 a Git repository : Begin

# tar and bzip2 a Git repository, excluding the node_modules subtree

gtb()
{
	# tar cv --exclude=node_modules "$1" | bzip2 -9 - > "$1.tar.bz2"
	# tar cjfv "$1.tar.bz2" --exclude=node_modules "$1"
	tar cjfv "$1_$(date --utc +%Y-%m-%d_%H-%M-%S).tar.bz2" --exclude=node_modules "$1"
}

# tar and bzip2 a Git repository, excluding the .git and node_modules subtrees

gtbx()
{
	# tar cv --exclude=.git --exclude=node_modules "$1" | bzip2 -9 - > "$1.tar.bz2"
	# tar cjfv "$1.tar.bz2" --exclude=.git --exclude=node_modules "$1"
	tar cjfv "$1_$(date --utc +%Y-%m-%d_%H-%M-%S).tar.bz2" --exclude=.git --exclude=node_modules "$1"
}

gtbc()
{
	CURRENT_DIR_NAME=$(basename $(pwd))
	cd ..
	gtb $CURRENT_DIR_NAME
	cd $CURRENT_DIR_NAME
}

gtbxc()
{
	CURRENT_DIR_NAME=$(basename $(pwd))
	cd ..
	gtbx $CURRENT_DIR_NAME
	cd $CURRENT_DIR_NAME
}

# tar and bzip2 a Git repository : End

# recursive_grep()		# See fstr above.
# {
	# grep -R -i --include="$1" "$2" .
# }

# ts()
# {
	# grep -R -i --include="*.txt" "$1" .
	# recursive_grep "*.txt" "$1"
# }

ggx()
{
	# grep -R --exclude-dir=".git" --exclude-dir="node_modules" --exclude-dir="deprecated" "$1" .

	# See lll in .bash_aliases
	grep -R --exclude-dir=".git" --exclude-dir="node_modules" --exclude-dir="deprecated" "$1" . | sed '/^.\{100,\}$/d'
}

ggxi()
{
	# grep -R -i --exclude-dir=".git" --exclude-dir="node_modules" --exclude-dir="deprecated" "$1" .
	grep -R -i --exclude-dir=".git" --exclude-dir="node_modules" --exclude-dir="deprecated" "$1" . | sed '/^.\{100,\}$/d'
}

run_script_if_it_exists()
{
	[ -f "$1" ] && . "$1"

	# ThAW 2017/08/30 : Is -s better than -f ?
	# [ -s "$1" ] && . "$1"
}

first2()
{
	od --endian=big -v -x "$1" | head -n 1 | cut -c 9-12
}

# .bash_aliases : See https://askubuntu.com/questions/17536/how-do-i-create-a-permanent-bash-alias

# run_script_if_it_exists ~/.bash_aliases
# run_script_if_it_exists ~/.bash_aliases_local
run_script_if_it_exists "$HOME/.bash_aliases"
run_script_if_it_exists "$HOME/.bash_aliases_local"
run_script_if_it_exists "$HOME/bin/determine_distro_core.sh"

# Initialize nvm (the Node.js version manager) if it is available.
# See https://github.com/creationix/nvm
export NVM_DIR=~/.nvm
# [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
# run_script_if_it_exists ~/.nvm/nvm.sh
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# run_script_if_it_exists "$NVM_DIR/bash_completion"

# Initialize rvm (the Ruby Version Manager) if it is available.
# See https://rvm.io/rvm/install
# export PATH="$PATH:$HOME/.rvm/bin"
# [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

if [ -d "/usr/local/rvm" ]; then
	[ -d "/usr/local/rvm/bin" ] && export PATH="$PATH:/usr/local/rvm/bin"
	run_script_if_it_exists "/usr/local/rvm/scripts/rvm"
elif [ -d "$HOME/.rvm" ]; then
	[ -d "$HOME/.rvm/bin" ] && export PATH="$PATH:$HOME/.rvm/bin"
	run_script_if_it_exists "$HOME/.rvm/scripts/rvm"
fi

echo -e "${BCyan}This is Bash version ${BRed}${BASH_VERSION%.*}${BCyan} - Display on ${BRed}$DISPLAY${NC}"
# which whoami 1>/dev/null 2>&1 && echo -e "You are: $(whoami)"
safe_eval 'echo -e "You are: $(whoami)"' whoami

# date --iso-3339=seconds
# date --iso-8601=seconds
# date --rfc-2822
safe_eval "date --rfc-3339=seconds"

safe_eval uptime

safe_eval 'echo -e "Host: $(hostname)"' hostname

# ****

pattern="model.name\s+: ([[:print:]]*)"

[[ $(cat /proc/cpuinfo) =~ $pattern ]] && echo "CPU model: ${BASH_REMATCH[1]}" || echo "Could not determine the CPU model."

# ****

echo -e "Number of CPU cores: $NCPU"

safe_eval 'echo -e "Platform: $(uname -o)"' uname

fooblah()
{
	which $1 1>/dev/null 2>&1 && eval $2
}

fooblah determine_distro 'echo -e "Distribution: $(determine_distro)"'

fooblah arch_bits 'echo -e "The system has a $(arch_bits)-bit architecture."'

FREE_M_OUTPUT=$(free -m 2>&1 | grep Mem)
[ -z "$FREE_M_OUTPUT" ] || {
	echo -e "Total memory: $(echo $FREE_M_OUTPUT | awk '{print $2}') MB"
	echo -e "Free memory: $(echo $FREE_M_OUTPUT | awk '{print $4}') MB"
}

echo -e "\nAvailable disk space:\n"
df -h
echo

hmm()
{
	# which $1 >/dev/null 2>&1 && echo "$1 is present." || echo "$1 is absent."
	which $1 >/dev/null 2>&1 && echo "$1 is installed." || echo "$1 is not installed."
}

# Check versions of Node.js and Ruby :

# To install thaw-latest-version-of :

# - Install git
# - Install Node.js (i.e. node and npm) (via nvm or nodist)
# $ git clone https://github.com/tom-weatherhead/http-get-regex-capture.git
# $ cd http-get-regex-capture
# $ npm i
# $ npm link

which thaw-latest-version-of 1>/dev/null 2>&1 && {

	which node >/dev/null 2>&1 && {
		# pattern="v(\S+)$"		# This works in WSL, but not in Cygwin.
		pattern="v(.+)"			# This works in WSL and Cygwin.
		if [[ $(node -v) =~ $pattern ]]; then echo "Currently using Node.js version ${BASH_REMATCH[1]}"; else echo "Could not determine the currently-used version of Node.js."; fi
		echo -e "Latest version of Node.js is $(thaw-latest-version-of node)"
		echo
	} || {
		echo "Node.js is not installed."
	}

	which ruby >/dev/null 2>&1 && {
		# pattern="ruby (\S+)p"	# This works in WSL, but not in Cygwin.
		pattern="ruby.(.+)p"	# This works in WSL and Cygwin.
		if [[ $(ruby -v) =~ $pattern ]]; then echo "Currently using Ruby version ${BASH_REMATCH[1]}"; else echo "Could not determine the currently-used version of Ruby."; fi
		echo -e "Latest version of Ruby is $(thaw-latest-version-of ruby)"
		echo
	} || {
		echo "Ruby is not installed."
	}
} || {
	echo "thaw-latest-version-of is not installed."
}
