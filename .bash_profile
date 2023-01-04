export PYTHONSTARTUP="$HOME/.pyrc"
export GOPATH="$HOME/.go"
export NVM_DIR="$HOME/.nvm"

[ -r "$HOME/.profile" ] && source "$HOME/.profile"

# Set PATH so it includes user's private bin if it exists
[ -d "$HOME/bin" ] && export PATH="$HOME/bin:$PATH"

# Set PATH so it includes user's private bin if it exists
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"

# Set PATH so it includes toolbox, if it exists
[ -d "$HOME/.toolbox/bin" ] && export PATH=$HOME/.toolbox/bin:$PATH

# Set up Go environment
[ -d "$GOPATH" ] && export PATH="$PATH:$GOPATH/bin"

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
