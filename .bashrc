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
alias mc='meson compile'
alias mi='meson install'

if [ "$TERM" != "linux" ] && [ -f "$GOPATH/bin/powerline-go" ]; then
  function _update_ps1() {
      PS1="$($GOPATH/bin/powerline-go -modules='aws,venv,user,ssh,cwd,perms,git,jobs,exit,root' -cwd-max-depth=3 -error $?)"
  }
  PROMPT_COMMAND="_update_ps1"
fi

[ -r "$HOME/.bashrc.local" ] && source $HOME/.bashrc.local
