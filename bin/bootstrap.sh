#!/bin/zsh -e

if [[ ! -r $HOME/dotfiles/.git ]]; then
  echo "Please clone dotfiles repo to $HOME/"
  exit 1
fi

echo "Note that this will overwrite the following files, if they exist:"
echo "  $HOME/.zshrc"
echo "  $HOME/.zprofile"
echo "  $HOME/.gitconfig"
echo "  $HOME/.pyrc"
echo "  $HOME/.tmux.conf"
echo "  $HOME/.config/nvim/init.lua"

if ! read -q "?Continue? (y/n) "; then
  exit 1
fi

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"

if [[ "$OSTYPE" =~ ^darwin ]]; then
  if [[ ! -x $(which brew) ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  fi
  if [[ ! -x $(which pyenv) ]]; then
    brew install pyenv # pyenv
  fi
  brew install go # For powerline
  brew install --cask cmake # For YouCompleteMe
  brew install nvim@0.10.0
elif [[ "$OSTYPE" =~ ^linux ]]; then
  if [[ ! -x $(which pyenv) ]]; then
    curl https://pyenv.run | zsh # pyenv
  fi
  sudo apt-get update
  sudo apt-get install build-essential gdb lcov pkg-config \
      libbz2-dev libffi-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
      libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev \
      lzma lzma-dev tk-dev uuid-dev zlib1g-dev tmux wget
  sudo add-apt-repository ppa:longsleep/golang-backports # go
  sudo apt-get update && sudo apt-get install golang-go # go
  nvim_sha256="6a021e9465fe3d3375e28c3e94c1c2c4f7d1a5a67e4a78cf52d18d77b1471390  $HOME/.local/bin/nvim.appimage"
  set +e
  echo "$nvim_sha256" | sha256sum --check > /dev/null
  nvim_ok=$?
  set -e
  if [ $nvim_ok -ne 0 ]; then
    wget -O $HOME/.local/bin/nvim.appimage https://github.com/neovim/neovim/releases/download/v0.10.0/nvim.appimage
    echo "$nvim_sha256" | sha256sum --check
    chmod +x $HOME/.local/bin/nvim.appimage
  fi
else
  echo "$OSTYPE is not darwin or linux."
  exit 1
fi

if read -q "?Install python? (y/n) "; then
    echo "Installing python"
    eval "$(pyenv init -)"
    _PYTHON_VERSION=3.12.1
    pyenv uninstall -f $_PYTHON_VERSION
    env PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install -f $_PYTHON_VERSION
    pyenv global $_PYTHON_VERSION
fi

# Install .profile
echo "Checking .profile"
if [[ ! -r $HOME/.profile ]]; then
  touch $HOME/.profile
fi

# Install .zprofile
if cmp --silent -- "$HOME/.zshrc" "$HOME/dotfiles/.zshrc"; then
  if read -q "?Overwrite $HOME/.zprofile? (y/n) "; then
    echo "Overwriting $HOME/.zprofile"
    pushd $HOME > /dev/null
    rm -f .zprofile
    ln -s dotfiles/.zprofile
    popd > /dev/null
  fi
fi

echo "Checking PATH"
mkdir -p $HOME/.local/bin
if [[ ! $PATH =~ "$HOME/.local/bin" ]]; then
  # This is needed for pip and powerline
  echo "Adding $HOME/.local/bin to PATH"
  export PATH=$PATH:$HOME/.local/bin
fi

if [[ ! $(grep ".local/bin" $HOME/.profile) ]]; then
  if read -q "?Add $HOME/.local/bin to PATH in $HOME/.profile? (y/n) "; then
    echo "export PATH=\$PATH:\$HOME/.local/bin" >> $HOME/.profile
  fi
fi

if [[ ! $(grep "pyenv" $HOME/.profile) ]]; then
  if read -q "?Add pyenv to $HOME/.profile? (y/n) "; then
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.profile
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.profile
    echo 'eval "$(pyenv init -)"' >> ~/.profile
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zprofile
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zprofile
    echo 'eval "$(pyenv init -)"' >> ~/.zprofile
  fi
fi

if [[ ! $(grep ".zshrc" $HOME/.profile) ]]; then
  if read -q "?Add sourcing .zshrc in $HOME/.profile? (y/n) "; then
    echo "Adding source $HOME/.zshrc to $HOME/.zprofile"
    contents=$(cat <<-EOF

if [ -n "\$BASH_VERSION" ]; then
  # include .zshrc if it exists
  if [ -r "\$HOME/.zshrc" ]; then
    source "\$HOME/.zshrc"
  fi
fi
EOF
)
    echo "$contents" >> $HOME/.profile
  fi
fi

# Install .zshrc
echo "Checking .zshrc.local"
if [[ ! -r $HOME/.zshrc.local ]]; then
  if [[ -r $HOME/.zshrc ]]; then
    if read -q "?Move current $HOME/.zshrc to $HOME/.zshrc.local? (y/n) "; then
      echo "Moving $HOME/.zshrc to $HOME/.zshrc.local"
      mv $HOME/.zshrc $HOME/.zshrc.local
    fi
  fi
  # Check to see if a .zshrc.local was created by the previous check; if not, create it.
  if [[ ! -r $HOME/.zshrc.local ]]; then
    echo "Creating empty $HOME/.zshrc.local"
    touch $HOME/.zshrc.local
  fi
fi

echo "Checking .zshrc"
if [[ ! "$HOME/.zshrc" -ef "$HOME/dotfiles/.zshrc" ]]; then
  if read -q "?Overwrite $HOME/.zshrc? (y/n) "; then
    pushd $HOME > /dev/null
    rm -f .zshrc
    ln -s dotfiles/.zshrc
    popd > /dev/null
  fi
fi

echo "Installing pip modules"
pip_modules=(
  fancycompleter
  powerline-status
  powerline-shell
)

for pm in ${pip_modules[@]}; do
  if read -q "?Install python module $pm? (y/n) "; then
    pip3 install --user --use-pep517 $pm
  fi
done

echo "Installing go modules"
go_modules=(
  github.com/justjanne/powerline-go@latest
)

for gm in ${go_modules[@]}; do
  if read -q "?Install go module $gm? (y/n) "; then
    echo "Installing $gm"
    GOPROXY=direct go install $gm
  fi
done

echo "Note: fonts must be manually installed on host computer as well."
echo "See: https://github.com/powerline/fonts"
fonts_path="/tmp/$USER/fonts"
mkdir -p "$fonts_path"
git clone https://github.com/powerline/fonts.git "$fonts_path" --depth=1
pushd "$fonts_path" > /dev/null
./install.sh
popd > /dev/null
rm -rf "/tmp/$USER/fonts"

# Set up nvim
echo "Creating .vim/tmp"
mkdir -p $HOME/.config/nvim

echo "Checking for init.lua"
if [[ ! "$HOME/.config/nvim/init.lua" -ef "$HOME/dotfiles/nvim/init.lua" ]]; then
  echo "Linking init.lua"
  pushd $HOME/.config/nvim > /dev/null
  rm -f init.lua
  ln -s $HOME/dotfiles/nvim/init.lua
  popd > /dev/null
fi

echo "Checking for .gitconfig"
if [[ ! "$HOME/.gitconfig" -ef "$HOME/dotfiles/.gitconfig" ]]; then
  echo "Linking .gitconfig"
  pushd $HOME > /dev/null
  rm -f .gitconfig
  ln -s dotfiles/.gitconfig
  popd > /dev/null
fi

echo "Checking for .gitmessage"
if [[ ! "$HOME/.gitmessage" -ef "$HOME/dotfiles/.gitmessage" ]]; then
  echo "Linking .gitmessage"
  pushd $HOME > /dev/null
  rm -f .gitmessage
  ln -s dotfiles/.gitmessage
  popd > /dev/null
fi

echo "Checking for .gitconfig.local"
if [[ ! -r $HOME/.gitconfig.local ]]; then
  echo "Creating .gitconfig.local"
  read "git_user?Git username? "
  read "git_email?Git email? "
  contents=$(cat <<-EOF
[user]
  name = $git_user
  email = $git_email
EOF
)
  echo "$contents" > $HOME/.gitconfig.local
fi

echo "Checking for .tmux.conf"
if [[ ! "$HOME/.tmux.conf" -ef "$HOME/dotfiles/.tmux.conf" ]]; then
  echo "Linking .tmux.conf"
  pushd $HOME > /dev/null
  rm -f .tmux.conf
  ln -s dotfiles/.tmux.conf
  popd > /dev/null
fi

echo "Checking for .pyrc"
if [[ ! "$HOME/.pyrc" -ef "$HOME/.pyrc" ]]; then
  echo "Linking .tmux.conf"
  pushd $HOME > /dev/null
  rm -f .pyrc
  ln -s dotfiles/.pyrc
  popd > /dev/null
fi

echo "Complete."

exit 0
