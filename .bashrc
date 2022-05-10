SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

[ -z "$PS1" ] && return   # If not running interactively, don't do anything

# Surround branch name in square brackets if in a git repo.
# Otherwise do nothing.
git_branch() {
    BRANCH=$(git-branch-name.sh)
    if [[ -n ${BRANCH} ]]; then
        echo "[${BRANCH}]"
    fi
}

command_exists() {
    return $(command -v "$1" &> /dev/null)
}

path_contains() {
    if [[ $PATH =~ ^"$1":|:"$1":|:"$1"$ ]]; then
        return $(true)
    else
        return $(false)
    fi
}

augment_path() {
    IFS=":"
    read -a dirs <<< "$1"
    IFS=""

    for dir in "${dirs[@]}"
    do
        if ! $(path_contains "$dir"); then
            PATH="$dir:$PATH"
        fi
    done
}

NUM_COLORS=$(tput colors)

function prompt {
    source "${SOURCE_DIR}/.bash_lib/colors.bash"
    if [ -n NUM_COLORS ]; then
        case "$TERM" in
            xterm* ) echo "${a_red}\u@\h${df_clr}:${a_blue}\w${a_red}\$(git_branch)${df_clr}\$" ;;
            *) echo ""
        esac
    fi
}
PS1=$(prompt)

[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"
export HISTCONTROL=ignoredups
shopt -s checkwinsize

#
# Init script version managers
#

if [ -e /opt/homebrew/bin/brew ]; then
    augment_path /opt/homebrew/bin
fi

if $(command_exists brew); then
    HOMEBREW_PREFIX="$(brew --prefix)"

    # Use OpenJDK if homebrew has installed it.
    if [ -d "${HOMEBREW_PREFIX}/opt/openjdk" ]; then
        export JAVA_HOME="${HOMEBREW_PREFIX}/opt/openjdk"
    fi

    eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"

    NVM="$HOMEBREW_PREFIX/opt/nvm"
    if [ -e "$NVM/nvm.sh" ]; then
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM/nvm.sh" ] && . "$NVM/nvm.sh"  # This loads nvm
        [ -s "$NVM/etc/bash_completion.d/nvm" ] && . "$NVM/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
    fi
fi

if $(command_exists rbenv); then
    eval "$(rbenv init -)"
fi
if $(command_exists pyenv); then
    augment_path "${HOME}/.pyenv/shims"
    eval "$(pyenv init -)"
fi

# Python

export VIRTUAL_ENV_DISABLE_PROMPT=1
alias venv-activate='source .venv/bin/activate'
alias venv-deactivate='if [ -n "${VIRTUAL_ENV+set}" ]; then
    echo deactivating $VIRTUAL_ENV
    deactivate
fi'
alias venv-show='if [ -n "${VIRTUAL_ENV+set}" ]; then
    echo $VIRTUAL_ENV
fi'
alias ispark='PYSPARK_DRIVER_PYTHON=ipython pyspark'

#
# System-specific stuff.
#

if [[ $OSTYPE == "darwin"* ]]; then
    man_preview() {
        man -t $1 | open -f -a Preview
    }

    tcplisten() {
        # So there is no more google-ing for
        # https://stackoverflow.com/questions/4421633/who-is-listening-on-a-given-tcp-port-on-mac-os-x
        if [ "$1" -gt "-1" ]; then
           lsof -nP -i4TCP:$1 | grep LISTEN
        else
           lsof -nP -i4TCP | grep LISTEN
        fi
    }

    export CLICOLOR=1
    export BASH_SILENCE_DEPRECATION_WARNING=1

    if [ -z "${JAVA_HOME+set}" ]; then
        export JAVA_HOME=/Library/Java/Home
    fi

    # Aliases for opening files in various applications

    alias mn=man_preview

    alias code='"/Applications/Visual Studio Code.app//Contents/Resources/app/bin/code"'

    alias brave="open -a Brave\ Browser"
    alias chromium="open -a Chromium"

elif [ "linux-gnu" == $OSTYPE ] ; then

    eval `dircolors -b`

    if [ "$TERM" != "dumb" ]; then
        alias ls='ls --color=auto'
    fi
fi

export PATH
