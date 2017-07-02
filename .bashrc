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

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'
alias ........='cd ../../../../../../..'
alias .........='cd ../../../../../../../..'

# powerline-shell prompt command
function _update_ps1() {
    PS1="$($HOME/src/powerline-shell/powerline-shell.py $? 2> /dev/null)"
}
unset PROMPT_COMMAND
PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
