# .bashrc

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
