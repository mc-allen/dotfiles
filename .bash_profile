[ -r "$HOME/.profile" ] && source "$HOME/.profile"

# set PATH so it includes user's private bin if it exists
[ -d "$HOME/bin" ] && export PATH="$HOME/bin:$PATH"

# set PATH so it includes user's private bin if it exists
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"

# set PATH so it includes toolbox, if it exists
[ -d "$HOME/.toolbox/bin" ] && export PATH=$HOME/.toolbox/bin:$PATH

# set Go environment
[ -d "$GOPATH" ] && export PATH="$PATH:$GOPATH/bin"
