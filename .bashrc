# .bashrc

export PYTHONSTARTUP="$HOME/.pyrc"

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

function ffmpeg-mp4-transcode() {
  ffmpeg -i "$1" -pix_fmt yuv420p -c:a copy -movflags +faststart "$2"
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

alias tma='tmux attach'

if [ -r "$(which powerline-shell)" ]; then
  # powerline-shell prompt command
  function _update_ps1() {
    PS1="$(powerline-shell $?)"
  }
  unset PROMPT_COMMAND
  PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi

[ -r "$HOME/.bashrc.local" ] && source $HOME/.bashrc.local
[ -r "$SPACK_INSTALL_PATH" ] && source $SPACK_INSTALL_PATH/share/spack/setup-env.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
