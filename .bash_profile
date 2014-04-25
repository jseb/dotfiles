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

upgrade_casks() {
    old_ifs=$IFS
    IFS=$'\n'
    for cask in $(brew cask list)
    do
        caskname=$(awk '{ print $1 }' <<< $cask)
        if grep '(!)$' <<< $cask >/dev/null
        then
            echo "warning: the installed cask $caskname seems to be" \
                "unavailable in homebrew-cask, has it been renamed?" && continue
        fi
        brew cask info $cask | grep -qiF 'Not installed' \
            && brew cask uninstall $cask && brew cask install $cask
    done
    brew cask cleanup
    IFS=$old_ifs
}

pupdate() {
    bupdate
    upgrade_casks
    echo -n "--> upgrading npm packages.. "
    upgrade_npm && echo "success." || echo "failed."
    echo "--> re-linking node"
    relink_node
}

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
    npm update -gf --loglevel=error >/dev/null
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
export PS1="\$(git_prompt)"$PS1

alias p1="mpg123 -@ http://sverigesradio.se/topsy/direkt/132-hi-mp3.m3u"
alias p2="mpg123 -@ http://sverigesradio.se/topsy/direkt/163-hi-mp3.m3u"
alias p3="mpg123 -@ http://sverigesradio.se/topsy/direkt/164-hi-mp3.m3u"

