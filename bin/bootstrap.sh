#!/bin/bash -e

if [[ ! -r $HOME/dotfiles/.git ]]; then
  echo "Please clone dotfiles repo to $HOME/"
  exit 1
fi

# Install .bash_profile
confirm=""
while [[ ! $confirm == "y" && ! $confirm == "n" ]]; do
  read -p "Overwrite $HOME/.bash_profile? (y/n) " confirm
done
if [[ $confirm == "y" ]]; then
  echo "Overwriting $HOME/.bash_profile"
  rm -f $HOME/.bash_profile
  pushd $HOME > /dev/null
  ln -s $HOME/dotfiles/.bash_profile
  popd > /dev/null
fi

if [[ ! $PATH =~ "$HOME/.local/bin" ]]; then
  # This is needed for pip and powerline
  echo "Adding $HOME/.local/bin to PATH"
  export PATH=$PATH:$HOME/.local/bin

  # Check to see if .profile has this, but it wasn't source for some reason, such as maybe
  # $HOME/.bash_profile didn't reference it
  if [[ ! $(grep ".local/bin" $HOME/.profile) ]]; then
    confirm=""
    while [[ ! $confirm == "y" && ! $confirm == "n" ]]; do
      read -p "Add $HOME/.local/bin to PATH in $HOME/.profile? (y/n) " confirm
    done

    if [[ $confirm == "y" ]]; then
      echo 'export PATH=$PATH:$HOME/.local/bin' >> $HOME/.profile
    fi
  fi
fi

# Install .profile
echo "Checking .profile"
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
  confirm=""
  while [[ ! $confirm == "y" && ! $confirm == "n" ]]; do
    read -p "Move current $HOME/.bashrc to $HOME/.bashrc.local? (y/n) " confirm
  done

  if [[ $confirm == "y" ]]; then
    echo "Moving $HOME/.bashrc to $HOME/.bashrc.local"
    mv $HOME/.bashrc $HOME/.bashrc.local
  fi
fi

echo "Checking .bashrc"
if [[ $(readlink -f $HOME/.bashrc) != "$HOME/dotfiles/.bashrc" ]]; then
  confirm=""
  while [[ ! $confirm == "y" && ! $confirm == "n" ]]; do
    read -p "Overwrite $HOME/.bashrc? (y/n) " confirm
  done

  if [[ $confirm == "y" ]]; then
    rm -f $HOME/.bashrc
    pushd $HOME > /dev/null
    ln -s $HOME/dotfiles/.bashrc
    popd > /dev/null
  fi
fi

# Set up powerline
echo "Checking for powerline"
if [[ ! $(grep POWERLINE_CONF $HOME/.bashrc.local) ]]; then
  echo "Adding POWERLINE_CONFIG to $HOME/.bashrc.local"
  default_python_version=$(python -c "import sys; print '{}.{}'.format(sys.version_info.major, sys.version_info.minor)")
  echo "Default python version: $default_python_version: $default_python_site"
  pushd $HOME > /dev/null
  powerline_path="$(find .local/lib/python$default_python_version/site-packages -name powerline.conf)"
  echo "POWERLINE_CONF=\"$powerline_path\"" >> $HOME/.bashrc.local
  popd > /dev/null
fi

# Set up vim

echo "Creating .vim/tmp"
mkdir -p $HOME/.vim/tmp

echo "Checking for Vundle"
if [[ ! -r $HOME/.vim/bundle/Vundle.vim ]]; then
  echo "Cloning Vundle"
  git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
fi

echo "Checking for .vimrc"
if [[ ! -r $HOME/.vimrc ]]; then
  echo "Linking .vimrc"
  pushd $HOME > /dev/null
  ln -s $HOME/dotfiles/.vimrc
  popd > /dev/null
fi

echo "Checking for tab-multi-diff.vim plugin"
if [[ ! -r $HOME/dotfiles/.vim/plugin/tab-multi-diff.vim ]]; then
  echo "Linking tab-multi-diff.vim plugin"
  pushd $HOME/.vimrc/plugin > /dev/null
  ln -s $HOME/dotfiles/.vim/plugin/tab-multi-diff.vim
  popd > /dev/null
fi

echo "Installing vim plugins"
vim +PluginUpdate +PluginInstall +qall

echo "Checking for git-multidiff"
if [[ ! -r $HOME/.local/bin/git-multidiff ]]; then
  echo "Linking git-multidiff"
  pushd $HOME/.local/bin > /dev/null
  ln -s $HOME/dotfiles/git-multidiff
  popd > /dev/null
fi

echo "Checking for _git-multidiff-helper"
if [[ ! -r $HOME/.local/bin/_git-multidiff-helper ]]; then
  echo "Linking _git-multidiff-helper"
  pushd $HOME/.local/bin > /dev/null
  ln -s $HOME/dotfiles/_git-multidiff-helper
  popd > /dev/null
fi

echo "Checking for .gitconfig"
if [[ ! -r $HOME/.gitconfig ]]; then
  echo "Linking .gitconfig"
  pushd $HOME > /dev/null
  ln -s $HOME/dotfiles/.gitconfig
  popd > /dev/null
fi

if [[ ! $(grep ".gitconfig.local" $HOME/.gitconfig) ]]; then
  confirm=""
  while [[ ! $confirm == "y" && ! $confirm == "n" ]]; do
    read -p "Add .gitconfig.local to .gitconfig? (y/n) " confirm
  done
  if [[ $confirm == "y" ]]; then
    contents=$(cat <<-EOF
[include]
  path = ~/.gitconfig.local
EOF
)
    echo "$contents" >> $HOME/.gitconfig
  fi
fi

echo "Checking for .gitconfig.local"
if [[ ! -r $HOME/.gitconfig.local ]]; then
  echo "Creating .gitconfig.local"
  read -p "Git username?" git_user
  read -p "Git email?" git_email
  contents=$(cat <<-EOF
[user]
  name = $git_user
  email = $git_email
EOF
)
  echo "$contents" > $HOME/.gitconfig.local
fi

echo "Installing pip modules"
easy_install --user pip
easy_install3 --user pip
pip_modules=( fancycompleter powerline powerline-shell )
for pm in $pip_modules; do
  echo "Installing $pm"
  pip install --user $pm
  pip3 install --user $pm
done

echo "Note: fonts must be manually installed on host computer as well."
echo "See: https://github.com/powerline/fonts"
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts
./install.sh
cd ..
rm -rf fonts

exit 0
