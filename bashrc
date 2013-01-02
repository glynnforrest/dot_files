#Bash configuration
#Author: Glynn Forrest
#me@glynnforrest.com

#Check for an interactive session
[ -z "$PS1" ] && return

#Say something nice, only if we have fortune on the system
command_exists () {
    type "$1" &> /dev/null ;
}

if command_exists fortune; then
	fortune
fi

#And now for some motivation
echo
echo 'You have' $(grep '^\*+ TODO' -E ~/notes/dates/$(date +%Y-%B.org | tr '[A-Z]' '[a-z]') | wc -l) 'todos.'
echo

#Use vim as the default editor (good for servers with no emacs)
export EDITOR='vim'

export TERM=xterm-256color

#Edit file in an emacs session
alias e='emacsclient -n'

#Edit in vim
alias v='vim'

#Load bashmarks
source ~/.bash/bashmarks.sh

#Common aliases
alias ls='ls -h --group-directories-first --color=always'
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'

alias c='cd -'
alias ..='cd ..'
alias ...='cd ../..'

#mkdir a cd into it in one command
mkcd () {
	mkdir $1 -p && cd $1
}

#restart emacs server
er () {
	emacsclient -e '(my-kill-emacs)'; emacs -daemon
}

eb () {
	e ~/.bashrc
}

vb () {
	v ~/.bashrc
}

alias sb="source ~/.bashrc"

alias grep='grep --color=auto'

alias v='gvim --remote-silent'
alias png='ping www.google.com -c 5'
alias get='packer'
alias bin='sudo pacman -Rs'

alias pup='sudo pacman -Syu'
alias porph='pacman -Qqdt' #Show package orphans
alias pgr='pacman -Qq | grep -i' #Grep installed packages

alias gst='git status'
alias gch='git checkout'
alias gco='git commit'
alias gad='git add'
alias gcl='git clone'
alias gbr='git branch'
alias glo='git log'
alias gloo='git log --oneline'
alias gfe='git fetch'
alias gpul='git pull'
alias gpus='git push'
alias gme='git merge'
alias gdi='git diff'
alias gsu='git submodule'

alias psgr='ps -A | grep -i' #Grep for a process
alias mysq='mysql -u root -p'
alias starwars='telnet towel.blinkenlights.nl'

#Now load machine specific or private aliases
if [ -f ~/.bashrc.local ]
then
	source ~/.bashrc.local
fi

#Ignore duplicates in history
HISTCONTROL=ignoredups:ignorespace

#Navigate history with up/down based on what is already typed.
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

git_branch() {
	BR=$(git symbolic-ref HEAD 2>/dev/null) || { echo "$@" ; exit ; }
	BR=${BR#refs/heads/}
	echo "($BR) "
}

#View the list of packages installed explicity
pexp () {
	pacman -Qei $(pacman -Qu|cut -d" " -f 1)|awk ' BEGIN {FS=":"}/^Name/{printf("\033[1;36m%s\033[1;37m", $2)}/^Description/{print $2}'
}

# Extract Stuff
extract () {
if [ -f $1 ]; then
file=$(pwd)'/'$1
dir=$(echo $1 | grep -Po '[a-z]+' | head -n 1)
mkdir -p $dir; cd $dir
    case $1 in
             *.tar.bz2)   tar xjf $file; cd ../        ;;
             *.tar.gz)    tar xzf $file; cd ../     ;;
             *.bz2)       bunzip2 $file; cd ../       ;;
             *.rar)       unrar e $file; cd ../     ;;
             *.gz)        gunzip $file; cd ../     ;;
             *.tar)       tar xf $file; cd ../        ;;
             *.tbz2)      tar xjf $file; cd ../      ;;
             *.tgz)       tar xzf $file; cd ../       ;;
             *.zip)       unzip $file; cd ../     ;;
             *.Z)         uncompress $file; cd ../  ;;
             *.7z)        7z x $file; cd ../    ;;
             *)           echo "'$1' cannot be extracted via extract()" ;;
         esac
else
         echo "'$1' is not a valid file"
fi
}

#[user@host] cwd $
PS1='\[\033[36m\][\[\033[37m\]\u\[\033[36m\]@\[\033[37m\]\h\[\033[36m\]]\[\033[37m\] \W/\[\033[32m\] $(git_branch)\[\033[36m\]$ \[\033[0m\]'

#[user] cwd $
#PS1='\[\033[36m\][\[\033[37m\]\u\[\033[36m\]]\[\033[37m\] \W/\[\033[32m\] $(git_branch)\[\033[36m\]$ \[\033[0m\]'

#Get all the binaries
PATH=$PATH:usr/include

set visible-stats on

#Autocomplete the following
complete -cf sudo
complete -cf man
complete -cf bin
complete -cf killall

alias vx="vim /home/glynn/.xmonad/xmonad.hs"
alias re="xmonad --recompile"
alias youtube-mp3="youtube-dl -t --extract-audio --audio-format mp3 --audio-quality 320k"
