# basic helpers
is_mac () {
    test `uname` = "Darwin"
}

distro () {
    cat /etc/*release | head -n 1 | cut -d \" -f 2
}

is_debian () {
    test `distro | cut -d ' ' -f 1` = "Debian"
}

command_exists () {
    type "$1" &> /dev/null;
}

# environment variables
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

export GOPATH=~/code/go

PATH+=:$GOPATH/bin
PATH+=:~/.bin
PATH+=:~/.composer/vendor/bin
PATH+=:~/.phpenv/bin
PATH+=:~/.rvm/bin
PATH+=:~/.local/bin

if is_mac; then
    PATH+=:/usr/local/texlive/2016/bin/x86_64-darwin
fi;

if command_exists emacs; then
    export EDITOR='emacsclient -nw'
else
    export EDITOR='vim'
fi;

export FZF_DEFAULT_OPTS='--height 40% --reverse --border'

# zsh settings
# http://zsh.sourceforge.net/Doc/Release/zsh_toc.html
# look in $fpath for possible autoload options
setopt autocd
unsetopt correct_all
# get Ctrl-A and Ctrl-E working in tmux
bindkey -e

# history
HISTFILE="$HOME/.zsh_history"
# max length of session history
HISTSIZE=50000
# max length of history file
SAVEHIST=100000
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history
setopt share_history

# M-p and M-n to fuzzy search through history
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
bindkey "^[p" up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[n" down-line-or-beginning-search

# completion
autoload -Uz compinit
compinit
# Run this when shown 'zsh compinit: insecure directories, run
# compaudit for list.'
compinit-fix() {
    compaudit | xargs chmod g-w
}

# don't autoselect the first candidate
unsetopt menu_complete
# show position in completion menu
setopt auto_menu
setopt complete_in_word
setopt always_to_end
# use the menu
zstyle ':completion:*:*:*:*:*' menu select
# case insensitive
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
# complete . and ..
zstyle ':completion:*' special-dirs true
# cache slow autocomplete functions
zstyle ':completion::complete:*' use-cache 1

if [[ "${terminfo[kdch1]}" != "" ]]; then
  bindkey "${terminfo[kdch1]}" delete-char
fi

# delete partial words
autoload -U select-word-style
select-word-style bash

# quote pasted URLs
autoload -Uz url-quote-magic bracketed-paste-magic
zle -N self-insert url-quote-magic
zle -N bracketed-paste bracketed-paste-magic

# edit current command with C-xC-e
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

# ls -G config
LSCOLORS="Bx" # dir
LSCOLORS+="Fx" # symlink
LSCOLORS+="bx" # socket
LSCOLORS+="bx" # pipe
LSCOLORS+="gx" # executable
LSCOLORS+="bx" # block special
LSCOLORS+="bx" # character special
LSCOLORS+="gx" # executable with setuid bit
LSCOLORS+="gx" # executable with setgid bit
LSCOLORS+="ac" # dir globally writable with sticky bit
LSCOLORS+="ac" # dir globally writable without sticky bit
export LSCOLORS

# show lscolors in completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# splash of colour in manpages
# 1 is red
export LESS_TERMCAP_md=$(tput bold; tput setaf 1)

# prompt
setopt promptsubst

_git-prompt() {
    if test -f .git/HEAD
    then
        echo -n "%F{67}on%f "
        echo -n "$(set -o pipefail; git symbolic-ref HEAD -q | cut -c12- || cat .git/HEAD)"
        if test -n "`git status -s`"
        then
            echo -n "%F{67}*%f"
        fi
    fi
}

PROMPT='%n %F{67}at%f %M %F{67}in%f %~ $(_git-prompt)
%(0?..%F{red}%?%f )$ '

# functions
path () {
    echo $PATH | tr -s ':' '\n'
}

mkcd () {
    mkdir -p $1 && cd $1
}

# move up directories quickly, e.g. up 3 is cd ../../../
up() {
    local x='';for i in $(seq ${1:-1});do x="$x../"; done;cd $x;
}

emptydirs () {
    find $1 -type d -empty
}

rmemptydirs () {
    find $1 -type d -empty -delete
}

sy() {
    if test -f app/console; then
        ./app/console $*
    else
        ./bin/console $*
    fi;
}

# Copy a file to Desktop to make temporary changes, e.g. rename it
# before sending to someone
# with no args, just go to desktop
desk() {
    if test $# -ne 1
    then
        cd ~/Desktop/
    else
        cp -v $1 ~/Desktop/
    fi;
}

git-since () {
    git log --oneline --pretty=format:"%h - %an, %ad : %s" --since="$1"
}

git-between () {
    git log --oneline --pretty=format:"%h - %an, %ad : %s" --since="$1" --until="$2"
}

# create / attach to tmux sessions with fuzzy matching
tm() {
  [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
  if [ $1 ]; then
    tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s $1 && tmux $change -t "$1"); return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --select-1 --exit-0) &&  tmux $change -t "$session" || echo "No sessions found."
}

dl() {
    (cd ~/Downloads/; curl -L -O $1)
}

placeholder () {
    wget http://placekitten.com/$1/$2 -O $1\x$2.jpg
}

troll () {
    export PS1='C:${PWD//\//\\}> '
    clear
}

# aliases
alias c='cd -'
alias e='emacsclient -nw'
alias ez="e ~/.zshrc"
alias ff='find . -iname'
alias l='ls -lah'
alias ls='ls -h --group-directories-first --color=always'
alias lsbin='ls -1 ~/.bin'
alias myip='curl -L https://canihazip.com/s/'
alias mysq='mysql -u root -p'
alias pjson='python -mjson.tool'
alias png='ping -c 5 www.google.com'
alias sz="source ~/.zshrc"
alias vs='vagrant ssh'
alias vu='vagrant up'
alias vh='vagrant halt'
alias vr='vagrant reload'
alias vg='vagrant global-status'
alias vp='vagrant provision'
alias vsus='vagrant suspend'
alias docker_rm_containers='docker rm `docker ps -aq --no-trunc -f status=exited`'
alias docker_rm_images='docker rmi `docker images -q -f dangling=true`'
alias docker_rm_all_images='docker rmi `docker images -q`'
alias dpostgres='docker run -ti --rm --name pg -p 5432:5432 -e POSTGRES_PASSWORD=postgres postgres'
alias dmysql='docker run -ti --rm --name=mysql -p 3306:3306 -e MYSQL_USER=my -e MYSQL_PASSWORD=my -e MYSQL_DATABASE=my mysql/mysql-server:5.7'
alias comi='composer install'
alias comu='composer update'
alias comr='composer require'
# grep for a process
alias psgr='ps -A | grep -i'
# vagrant on MacOS sometimes has permission errors due to stale NFS file handles.
# use this to jog its memory.
alias jog='ls -Ra > /dev/null'
# combine pdfs
# pdf_combine 1.pdf 2.pdf
# OR
# pdf_combine *.pdf
# creates output.pdf
# the input files are printed after 'from' when gs is followed by a command
# (echo), but doesn't output anything normally. I have no idea why.
alias pdf_combine='gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=output.pdf && echo "created output.pdf from"'
alias clone='cd ~/Desktop && git clone'
# sometimes Chrome favicon cache needs a kick
alias rm_chrome_favicons='rm ~/Library/Application\ Support/Google/Chrome/Default/Favicons'
alias pygment_styles='python -c "from pygments.styles import get_all_styles; print(list(get_all_styles()))"'
alias starwars='telnet towel.blinkenlights.nl'
alias youtube_mp3="youtube-dl -t --extract-audio --audio-format mp3 --audio-quality 320k"

# Defaults to port 8000
# python_server <port> for a different port
alias python_server="python -m SimpleHTTPServer"

if command_exists fasd;
then;
    eval "$(fasd --init auto)"

    alias a='fasd -a'        # any
    alias s='fasd -si'       # show / search / select
    alias d='fasd -d'        # directory
    alias f='fasd -f'        # file
    alias sd='fasd -sid'     # interactive directory selection
    alias sf='fasd -sif'     # interactive file selection
    alias z='fasd_cd -d'     # cd, same functionality as j in autojump
    alias zz='fasd_cd -d -i' # cd with interactive selection

    ee () {e `fasd -sif $1`}
fi;

# platform-specific aliases
if is_mac; then
    alias ls='ls -h -G'
    alias reset_dns='sudo killall -HUP mDNSResponder'
    alias brew-dump='(cd ~/code/github.com/glynnforrest/dotfiles/ && brew bundle dump --force && echo "Updated Brewfile")'
else;
    alias open='xdg-open'
fi;

# z.sh
if test -f ~/.bin/z.sh
then
    source ~/.bin/z.sh
fi;

# load private configuration if available
if test -f ~/.zshrc.local
then
    source ~/.zshrc.local
fi
