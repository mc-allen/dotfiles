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

# Load pyenv automatically by adding the following to ~/.bashrc:
[ -d "$HOME/.pyenv/bin" ] && export PATH="$HOME/.pyenv/bin:$PATH"

# Set up Go environment
[ -d "$GOPATH" ] && export PATH="$PATH:$GOPATH/bin"

# Set up Rust environment
[ -d "$HOME/.cargo/bin" ] && export PATH="$HOME/.cargo/bin:$PATH"
