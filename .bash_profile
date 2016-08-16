export HISTCONTROL=ignoredups:erasedups
export GIT_TREE=~/git_worktree
export HISTSIZE=10000
shopt -s histappend

export PROMPT_COMMAND="history -n; history -w; history -c; history -r"
export EDITOR=vim
# Cairo requires this (AssetGraph related..)
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/opt/X11/lib/pkgconfig

bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

alias ls="ls -lahG"
alias s="git status"

bupdate() {
    for action in update doctor upgrade cleanup
    do
        echo "--> brew $action" && brew $action
    done
}

relink_node() {
    brew unlink node && brew link --overwrite node
}

upgrade_npm() {
    npm update -gf --loglevel=error 1>/dev/null 2>/dev/null || \
        echo "there was a problem with upgrading npm packages.."
}

fetch() {
    [[ ! "$GIT_TREE" ]] && return
    cd $GIT_TREE
    find . -name .git -type d -exec bash -c "echo -n '--> fetching ' &&
        dirname {} | egrep -o '\w+.*' && cd {} && cd .. && git remote update" \;
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
source $(get_source_dir)/lib/git-prompt/git-prompt
PROMPT_COMMAND="$PROMPT_COMMAND; git_prompt"

alias p1="mpg123 -@ http://sverigesradio.se/topsy/direkt/132-hi-mp3.m3u"
alias p2="mpg123 -@ http://sverigesradio.se/topsy/direkt/163-hi-mp3.m3u"
alias p3="mpg123 -@ http://sverigesradio.se/topsy/direkt/164-hi-mp3.m3u"

export PATH="/usr/local/sbin:$PATH"
hour=$(date +"%H")
if [ "$hour" -ge 6 -a "$hour" -le 17 ]
then
    colorscheme='Solarized Light'
else
    colorscheme='Solarized Dark'
fi
setting="(first settings set whose name is \"$colorscheme\")"
osascript << END
tell application "Terminal"
    repeat with w from 1 to count windows
        repeat with t from 1 to count tabs of window w
            set current settings of tab t of window w to $setting
        end repeat
    end repeat
end tell
END
