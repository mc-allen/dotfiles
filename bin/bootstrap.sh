#!/bin/bash -e

if [[ ! -r $HOME/dotfiles/.git ]]; then
  echo "Please clone dotfiles repo to $HOME/"
  exit 1
fi

default_python_version=$(python -c "import sys; print '{}.{}'.format(sys.version_info.major, sys.version_info.minor)")
echo "Default python version: $default_python_version"

echo "Installing pip modules"
pip_modules=(
  fancycompleter
  git+git://github.com/powerline/powerline
  git+git://github.com/b-ryan/powerline-shell
)
easy_install --user pip
for pm in ${pip_modules[@]}; do
  confirm=""
  while [[ ! $confirm == "y" && ! $confirm == "n" ]]; do
    read -p "Install python module $pm? (y/n) " confirm
  done
  if [[ $confirm == "y" ]]; then
    echo "Installing $pm"
    pip install --user $pm
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

# Check to see if .profile has this, but it wasn't source for some reason, such as maybe
# $HOME/.bash_profile didn't reference it
if [[ ! $(grep ".local/bin" $HOME/.profile) ]]; then
  confirm=""
  while [[ ! $confirm == "y" && ! $confirm == "n" ]]; do
    read -p "Add $HOME/.local/bin to PATH in $HOME/.profile? (y/n) " confirm
  done

  if [[ $confirm == "y" ]]; then
    echo "export PATH=\$PATH:\$HOME/.local/bin" >> $HOME/.profile
  fi
fi

if [[ $(uname) == "Darwin" ]]; then
  darwin_python_bin="Library/Python/$default_python_version/bin"
  if [[ ! $PATH =~ "$HOME/$darwin_python_bin" ]]; then
    echo "Adding $HOME/$darwin_python_bin to PATH"
    export PATH=$PATH:$HOME/$darwin_python_bin
  fi
  # Check to see if .profile has this, but it wasn't source for some reason, such as maybe
  # $HOME/.bash_profile didn't reference it
  if [[ ! $(grep "$darwin_python_bin" $HOME/.profile) ]]; then
    confirm=""
    while [[ ! $confirm == "y" && ! $confirm == "n" ]]; do
      read -p "Add $darwin_python_bin to PATH in $HOME/.profile? (y/n) " confirm
    done

    if [[ $confirm == "y" ]]; then
      echo "export PATH=\$PATH:\$HOME/$darwin_python_bin" >> $HOME/.profile
    fi
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

echo "Checking for tab-multi-diff.vim plugin"
mkdir -p $HOME/.vim/plugin
if [[ ! "$HOME/.vim/plugin/tab-multi-diff.vim" -ef "$HOME/dotfiles/.vim/plugin/tab-multi-diff.vim" ]]; then
  echo "Linking tab-multi-diff.vim plugin"
  pushd $HOME/.vim/plugin > /dev/null
  rm -f tab-multi-diff.vim
  ln -s ../../dotfiles/.vim/plugin/tab-multi-diff.vim
  popd > /dev/null
fi

echo "Installing vim plugins"
vim +PluginUpdate +PluginInstall +qall

echo "Checking for git-multidiff"
if [[ ! "$HOME/.local/bin/git-multidiff" -ef "$HOME/dotfiles/bin/git-multidiff" ]]; then
  echo "Linking git-multidiff"
  pushd $HOME/.local/bin > /dev/null
  rm -f git-multidiff
  ln -s ../../dotfiles/bin/git-multidiff
  popd > /dev/null
fi

echo "Checking for _git-multidiff-helper"
if [[ ! "$HOME/.local/bin/_git-multidiff-helper" -ef "$HOME/dotfiles/bin/_git-multidiff-helper" ]]; then
  echo "Linking _git-multidiff-helper"
  pushd $HOME/.local/bin > /dev/null
  rm -f _git-multidiff-helper
  ln -s ../../dotfiles/bin/_git-multidiff-helper
  popd > /dev/null
fi

if [[ -r "$HOME/.vim/bundle/YouCompleteMe/install.py" ]]; then
  confirm=""
  while [[ ! $confirm == "y" && ! $confirm == "n" ]]; do
    read -p "Install YouCompleteMe? (y/n) " confirm
  done

  if [[ $confirm == "y" ]]; then
    echo "Installing YouCompleteMe"
    $HOME/.vim/bundle/YouCompleteMe/install.py
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

exit 0
