# .bashrc

export PYTHONSTARTUP="$HOME/.pyrc"
export GOPATH="$HOME/.go"

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

if [ "$TERM" != "linux" ] && [ -f "$GOPATH/bin/powerline-go" ]; then
  function _update_ps1() {
      PS1="$($GOPATH/bin/powerline-go -error $?)"
  }
  PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
elif [ -x "$(which powerline-shell)" ]; then
  powerline-shell -h > /dev/null 2>&1 
  if [ $? -eq 0 ]; then
    # powerline-shell prompt command
    function _update_ps1() {
      PS1="$(powerline-shell $?)"
    }
    unset PROMPT_COMMAND
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
  fi
fi

[ -r "$HOME/.bashrc.local" ] && source $HOME/.bashrc.local
[ -r "$SPACK_INSTALL_PATH" ] && source $SPACK_INSTALL_PATH/share/spack/setup-env.sh

if [ -x "$(which pyenv)" ]; then
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
