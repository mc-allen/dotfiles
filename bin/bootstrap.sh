#!/bin/bash -e

if [[ ! -r $HOME/dotfiles/.git ]]; then
  echo "Please clone dotfiles repo to $HOME/"
  exit 1
fi

echo "Note that this will overwrite the following files, if they exist:"
echo "  $HOME/.bashrc"
echo "  $HOME/.bash_profile"
echo "  $HOME/.gitconfig"
echo "  $HOME/.pyrc"
echo "  $HOME/.tmux.conf"
echo "  $HOME/.vimrc"

while [[ ! $confirm == "y" && ! $confirm == "n" ]]; do
  read -p "Continue? (y/n) " confirm
done
if [[ $confirm != "y" ]]; then
  exit 1
fi

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"

if [[ "$OSTYPE" =~ ^darwin ]]; then
  if [[ ! -x $(which brew) ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  fi
  if [[ ! -x $(which pip3) ]]; then
    brew install pyenv # pyenv
  fi
  brew install go # For powerline
  brew install --cask cmake # For YouCompleteMe
elif [[ "$OSTYPE" =~ ^linux ]]; then
  if [[ ! -x $(which pyenv) ]]; then
    curl https://pyenv.run | bash # pyenv
  fi
  sudo apt-get update
  sudo apt-get install build-essential gdb lcov pkg-config \
      libbz2-dev libffi-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
      libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev \
      lzma lzma-dev tk-dev uuid-dev zlib1g-dev tmux
  sudo add-apt-repository ppa:longsleep/golang-backports # go
  sudo apt-get update && sudo apt-get install golang-go # go
else
  echo "$OSTYPE is not darwin or linux."
  exit 1
fi

echo "Installing python"
eval "$(pyenv init -)"
_PYTHON_VERSION=3.11.1
pyenv uninstall -f $_PYTHON_VERSION
env PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install -f $_PYTHON_VERSION
pyenv global $_PYTHON_VERSION

# Install .profile
echo "Checking .profile"
if [[ ! -r $HOME/.profile ]]; then
  touch $HOME/.profile
fi

# Install .bash_profile
if [[ ! "$HOME/.bashrc" -ef "$HOME/dotfiles/.bashrc" ]]; then
  confirm=""
  while [[ ! $confirm == "y" && ! $confirm == "n" ]]; do
    read -p "Overwrite $HOME/.bash_profile? (y/n) " confirm
  done
  if [[ $confirm == "y" ]]; then
    echo "Overwriting $HOME/.bash_profile"
    pushd $HOME > /dev/null
    rm -f .bash_profile
    ln -s dotfiles/.bash_profile
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
  confirm=""
  while [[ ! $confirm == "y" && ! $confirm == "n" ]]; do
    read -p "Add $HOME/.local/bin to PATH in $HOME/.profile? (y/n) " confirm
  done

  if [[ $confirm == "y" ]]; then
    echo "export PATH=\$PATH:\$HOME/.local/bin" >> $HOME/.profile
  fi
fi

if [[ ! $(grep "pyenv" $HOME/.profile) ]]; then
  confirm=""
  while [[ ! $confirm == "y" && ! $confirm == "n" ]]; do
    read -p "Add pyenv to $HOME/.profile? (y/n) " confirm
  done
  
  if [[ $confirm == "y" ]]; then
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.profile
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.profile
    echo 'eval "$(pyenv init -)"' >> ~/.profile
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile
    echo 'eval "$(pyenv init -)"' >> ~/.bash_profile
  fi
fi

if [[ ! $(grep ".bashrc" $HOME/.profile) ]]; then
  confirm=""
  while [[ ! $confirm == "y" && ! $confirm == "n" ]]; do
    read -p "Add sourcing .bashrc in $HOME/.profile? (y/n) " confirm
  done

  if [[ $confirm == "y" ]]; then
    echo "Adding source $HOME/.bashrc to $HOME/.bash_profile"
    contents=$(cat <<-EOF

if [ -n "\$BASH_VERSION" ]; then
  # include .bashrc if it exists
  if [ -r "\$HOME/.bashrc" ]; then
    source "\$HOME/.bashrc"
  fi
fi
EOF
)
    echo "$contents" >> $HOME/.profile
  fi
fi

# Install .bashrc
echo "Checking .bashrc.local"
if [[ ! -r $HOME/.bashrc.local ]]; then
  if [[ -r $HOME/.bashrc ]]; then
    confirm=""
    while [[ ! $confirm == "y" && ! $confirm == "n" ]]; do
      read -p "Move current $HOME/.bashrc to $HOME/.bashrc.local? (y/n) " confirm
    done

    if [[ $confirm == "y" ]]; then
      echo "Moving $HOME/.bashrc to $HOME/.bashrc.local"
      mv $HOME/.bashrc $HOME/.bashrc.local
    fi
  fi
  # Check to see if a .bashrc.local was created by the previous check; if not, create it.
  if [[ ! -r $HOME/.bashrc.local ]]; then
    echo "Creating empty $HOME/.bashrc.local"
    touch $HOME/.bashrc.local
  fi
fi

echo "Checking .bashrc"
if [[ ! "$HOME/.bashrc" -ef "$HOME/dotfiles/.bashrc" ]]; then
  confirm=""
  while [[ ! $confirm == "y" && ! $confirm == "n" ]]; do
    read -p "Overwrite $HOME/.bashrc? (y/n) " confirm
  done

  if [[ $confirm == "y" ]]; then
    pushd $HOME > /dev/null
    rm -f .bashrc
    ln -s dotfiles/.bashrc
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
  confirm=""
  while [[ ! $confirm == "y" && ! $confirm == "n" ]]; do
    read -p "Install python module $pm? (y/n) " confirm
  done
  if [[ $confirm == "y" ]]; then
    echo "Installing $pm"
    pip3 install --user --use-pep517 $pm
  fi
done

echo "Installing go modules"
go_modules=(
  github.com/justjanne/powerline-go@latest
)

for gm in ${go_modules[@]}; do
  confirm=""
  while [[ ! $confirm == "y" && ! $confirm == "n" ]]; do
    read -p "Install go module $gm? (y/n) " confirm
  done
  if [[ $confirm == "y" ]]; then
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

# Set up vim
echo "Creating .vim/tmp"
mkdir -p $HOME/.vim/tmp

echo "Checking for Vundle"
mkdir -p $HOME/.vim/bundle
if [[ ! -r $HOME/.vim/bundle/Vundle.vim ]]; then
  echo "Cloning Vundle"
  git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
fi

echo "Checking for .vimrc"
if [[ ! "$HOME/.vimrc" -ef "$HOME/dotfiles/.vimrc" ]]; then
  echo "Linking .vimrc"
  pushd $HOME > /dev/null
  rm -f .vimrc
  ln -s dotfiles/.vimrc
  popd > /dev/null
fi


if [[ "$OSTYPE" =~ ^darwin ]]; then
  brew install vim # For youcompleteme python support
fi

echo "Installing vim plugins"
vim +PluginUpdate +PluginInstall +qall

if [[ -r "$HOME/.vim/bundle/YouCompleteMe/install.py" ]]; then
  confirm=""
  while [[ ! $confirm == "y" && ! $confirm == "n" ]]; do
    read -p "Install YouCompleteMe? (y/n) " confirm
  done

  if [[ $confirm == "y" ]]; then
    echo "Installing YouCompleteMe"
    if [[ "$OSTYPE" =~ ^darwin ]]; then
      brew install ctags
    elif [[ "$OSTYPE" =~ ^linux ]]; then
      sudo apt install build-essential cmake vim-nox python3-dev
    fi
    $HOME/.vim/bundle/YouCompleteMe/install.py --clang-completer
  fi
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

echo "Checking for .git-completion.bash"
if [[ ! "$HOME/.git-completion.bash" -ef "$HOME/dotfiles/.git-completion.bash" ]]; then
  echo "Linking .git-completion.bash"
  pushd $HOME > /dev/null
  rm -f .git-completion.bash
  ln -s dotfiles/.git-completion.bash
  popd > /dev/null
fi

echo "Checking for .gitconfig.local"
if [[ ! -r $HOME/.gitconfig.local ]]; then
  echo "Creating .gitconfig.local"
  read -p "Git username? " git_user
  read -p "Git email? " git_email
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
echo "Add .bashrc settings to .bashrc.local"
echo "Add .gitconfig settings to .gitconfig.local"
echo "Add .bash_profile/.profile settings to .profile"

exit 0
