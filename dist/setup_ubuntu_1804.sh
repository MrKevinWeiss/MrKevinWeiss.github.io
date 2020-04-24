#!/usr/bin/env bash

echo Installing apt packages >&2
sudo apt-get update
sudo apt-get -y --no-install-recommends install \
build-essential \
clang \
clang-tools \
cppcheck \
curl \
doxygen \
gdb \
git \
python3 \
python3-dev \
python3-pip \
python3-setuptools \
python3-wheel \
python \
tmux \
uncrustify \
vera++ \
vim \
vim-common \
wget

sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

sudo mkdir -p /opt

# Install ARM GNU embedded toolchain
# For updates, see https://developer.arm.com/open-source/gnu-toolchain/gnu-rm/downloads
ARM_URLBASE=https://developer.arm.com/-/media/Files/downloads/gnu-rm
ARM_URL=${ARM_URLBASE}/9-2019q4/gcc-arm-none-eabi-9-2019-q4-major-x86_64-linux.tar.bz2
ARM_MD5=fe0029de4f4ec43cf7008944e34ff8cc
ARM_FOLDER=gcc-arm-none-eabi-9-2019-q4-major
echo 'Installing arm-none-eabi toolchain from arm.com' >&2 && \
    mkdir -p .tmp/opt && \
    curl -L -o .tmp/opt/gcc-arm-none-eabi.tar.bz2 ${ARM_URL} && \
    echo "${ARM_MD5} .tmp/opt/gcc-arm-none-eabi.tar.bz2" | md5sum -c && \
    tar -C .tmp/opt -jxf .tmp/opt/gcc-arm-none-eabi.tar.bz2 && \
    rm -f tmp/opt/gcc-arm-none-eabi.tar.bz2 && \
    echo 'Removing documentation' >&2 && \
    rm -rf .tmp/opt/gcc-arm-none-eabi-*/share/doc
    # No need to dedup, the ARM toolchain is already using hard links for the duplicated files
sudo mv .tmp/opt/${ARM_FOLDER} /opt/${ARM_FOLDER}
echo PATH=\${PATH}:/opt/${ARM_FOLDER}/bin > ~/.accelovant_env

sudo pip3 install --no-cache-dir flake8 \
codespell

read -p "Enter git username [$USER]: " gitusername
gitusername=${gitusername:-$USER}
read -p "Enter git email [$USER@accelovant.com]: " gitemail
gitemail=${gitemail:-$USER@accelovant.com}

sudo git config --system user.name $gitusername
sudo git config --system user.email $gitemail
git config --global core.autocrlf true

ssh-keygen -t rsa -b 4096 -C $gitemail

echo "Please copy your ssh public key to your github account: https://github.com/settings/keys" >&2
cat .ssh/id_rsa.pub

if [ -z "$1" ]
then
    mkdir -p wd
else
    echo "Creating link to $1" >&2
    ln -s $1 wd
fi

git clone --recurse-submodules git@github.com:MrKevinWeiss/Accelovant.git wd/Accelovant

grep -qxF 'set -g history-limit 10000' ~/.tmux.conf || echo 'set -g history-limit 10000' >> ~/.tmux.conf
grep -qxF 'set -g mouse on' ~/.tmux.conf || echo 'set -g mouse on' >> ~/.tmux.conf
grep -qxF 'set -g default-terminal "screen-256color"' ~/.tmux.conf || echo 'set -g default-terminal "screen-256color"' >> ~/.tmux.conf
grep -qxF 'set-window-option -g xterm-keys on' ~/.tmux.conf || echo 'set-window-option -g xterm-keys on' >> ~/.tmux.conf

grep -qxF 'set bell-style none' /etc/inputrc || echo 'set bell-style none' | sudo tee -a /etc/inputrc
grep -qxF 'source ~/.accelovant_env' ~/.bashrc || echo 'source ~/.accelovant_env' >> ~/.bashrc
source ~/.accelovant_env
