# .bashrc

function encrypt() {
  fname="$1"
  openssl aes-256-cbc -base64 -e -salt -in "$fname" -out "$(basename ${fname%.*})"
}

function decrypt() {
  fname="$1"
  openssl aes-256-cbc -base64 -d -salt -in "$fname" -out "$(basename ${fname%.*})"
}

function f() {
  if [[ $# = 0 ]]; then
    return -1
  else
    text="$1"
  fi

  if [[ $# > 1 ]]; then
    searchpath="$2"
  else
    searchpath="."
  fi

  if [[ $# > 2 ]]; then
    filefilter="$3"
  else
    filefilter="*"
  fi

  grep -r "$text" --include="$filefilter" "$searchpath"
}

alias ll='ls -Glah'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'
alias ........='cd ../../../../../../..'
alias .........='cd ../../../../../../../..'

alias ll='ls -lah'

# powerline-shell prompt command
function _update_ps1() {
  PS1="$(powerline-shell $?)"
}
unset PROMPT_COMMAND
PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
if [ -r "$HOME/.rvm/bin" ]; then
  export PATH="$PATH:$HOME/.rvm/bin"
fi

if [ -r $HOME/.bashrc.local ]; then
  source $HOME/.bashrc.local
fi
