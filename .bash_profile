#!/usr/bin/env bash

export HISTCONTROL=ignoredups:erasedups
export GIT_TREE=~/git_worktree
export HISTSIZE=100000
shopt -s histappend
shopt -s extglob

export PROMPT_COMMAND="history -n; history -w; history -c; history -r"
export EDITOR=vim

# Cairo requires this (AssetGraph related..)
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/opt/X11/lib/pkgconfig

bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

[ -t 1 ] && stty -ixon # enables ctrl-s for forward search in history

alias ls="ls -lahG"
alias s="git status"

bupdate() {
    for cmd in brew\ {update,doctor,upgrade,cleanup,prune}
    do
        echo "--> $cmd" && $cmd || return 1
    done
}

capitalize() {
    echo "$(tr '[:lower:]' '[:upper:]' <<< "${1:0:1}")$(tr '[:upper:]' '[:lower:]' <<< "${1:1}")"
}

upgrade_npm() {
    npm update -gf --loglevel=info
}

fetch_all() {
    [ -z "$GIT_TREE" ] && return
    find $GIT_TREE -name .git -type d | while read -r git_dir
    do
        repo_path=$(dirname "$git_dir")
        repo_name=$(sed -e 's/.*\///g' <<< "$repo_path")
        (
            cd "$git_dir/.." || exit 1
            if [ -z "$(git status --porcelain)" ]
            then
                echo "--> pulling $repo_name"
                git pull
            else
                echo "--> fetching $repo_name"
                git remote update
            fi
        )
    done
}

hr() {
    printf -- "${1:-=}%.0s" $(seq $COLUMNS)
}

get_source_dir() {
    source="${BASH_SOURCE[0]}"
    # resolve $source until the file is no longer a symlink
    while [ -h "$source" ]; do
        dir="$( cd -P "$( dirname "$source" )" && pwd )"
        source="$(readlink "$source")"
        # if $source was a relative symlink, we need to resolve it relative to
        # the path where the symlink file was located
        [[ $source != /* ]] && source="$dir/$source"
    done
    dir="$( cd -P "$( dirname "$source" )" && pwd )"
    echo "$dir"
}

cask_upgrade() {
    "$(get_source_dir)"/lib/cask-upgrade/cask-upgrade "$@"
}

source "$(get_source_dir)"/lib/git-prompt/git-prompt
PROMPT_COMMAND="$PROMPT_COMMAND; git_prompt"

alias p1="mpg123 -@ http://sverigesradio.se/topsy/direkt/132-hi-mp3.m3u"
alias p2="mpg123 -@ http://sverigesradio.se/topsy/direkt/163-hi-mp3.m3u"
alias p3="mpg123 -@ http://sverigesradio.se/topsy/direkt/164-hi-mp3.m3u"

tmp_file_prefix='7edd8f35'
color_tmp_file=/tmp/${tmp_file_prefix}_current_color
hour_tmp_file=/tmp/${tmp_file_prefix}_current_hour

for cache_file_name in $color_tmp_file $hour_tmp_file
do
    [ ! -f "$cache_file_name" ] && touch "$cache_file_name"
done

function set_color_scheme() {
    color_scheme=$(capitalize "$1")
    setting="(first settings set whose name is \"Solarized $color_scheme\")"
    osascript << END
tell application "Terminal"
    repeat with w from 1 to count windows
        repeat with t from 1 to count tabs of window w
            set current settings of tab t of window w to $setting
        end repeat
    end repeat
end tell
END
}

update_color_scheme() {
    previous_hour=$(cat ${hour_tmp_file})
    current_hour=$(date +"%H")
    if [ "$current_hour" -ne "${previous_hour:-25}" ]
    then
        if [ "$current_hour" -gt 8 ] && [ "$current_hour" -lt 18 ]
        then
            current_color='light'
        else
            current_color='dark'
        fi
        previous_color=$(cat ${color_tmp_file})
        if [ "$current_color" != "${previous_color:-''}" ]
        then
            set_color_scheme $current_color
            echo $current_color > ${color_tmp_file}
        fi
        echo "$current_hour" > "${hour_tmp_file}"
    fi
}

file=$(ls -C "$(brew --prefix)"/etc/bash_completion 2> /dev/null) && . "$file"

function f() {
    find . -iname "*$1*"
}

function fuz() {
    file=$(fzf -q "${2:-''}")
    "$1" "$file"
}

function playdir() {
    dir=${1:-'.'}
    mpg123 -Z "$(find "$dir" -iname '*.mp3' -print)"
}

# Much faster than /usr/bin/vim
alias vim="/Applications/MacVim.app/Contents/MacOS/Vim"

update() {
    echo "=> updating homebrew" && bupdate && \
    echo "=> upgrading casks" && cask_upgrade -n && \
    echo "=> upgrading npm" && upgrade_npm && \
    echo "=> fetching git repositories" && fetch_all
}

pid_by_port() {
    lsof -i tcp:"$1" | awk 'NR!=1 {print $2}' | uniq
}

# You can put these two commands in your local shell initialization script
# e.g. ~/.bashrc or ~/.zshrc
export LC_ALL=en_US.utf-8
export LANG=en_US.utf-8
