#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

pushd() {
  command pushd "$@" >/dev/null
}
popd() {
  command popd "$@" >/dev/null
}
export pushd popd

eval "$(zoxide init bash)"

ansible-playbook() {
    pyenv activate ansible
    ~/.pyenv/shims/ansible-playbook $@
    pyenv deactivate
}

alias ans="ansible-playbook"
alias dbuild="./tools/toolchain/dbuild"
alias docker=podman
alias ls='ls --color=auto -1'
alias ll='ls --color=auto -l'
alias grep='grep --color=auto'
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

export PS1="\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "

export XDG_CONFIG_HOME=~/.config

export TERM=xterm
export CC=/usr/bin/gcc
export CXX=/usr/bin/g++
export MAKEFLAGS=-j8
#export CFLAGS="-march=native -O2 -pipe"
#export CXXFLAGS="${CFLAGS}"
#export RUSTFLAGS="-C opt-level=2 -C target-cpu=native"
#export LDFLAGS="-fuse-ld=gold"

export _JAVA_AWT_WM_NONREPARENTING=1
export BROWSER=firefox
export EDITOR=nvim
export VIEW=nvim

export PATH=$PATH:$HOME/Applications/git-cola/bin/
export PATH=$PATH:$HOME/Applications/vscode/bin/

export GOPATH=~/go
export PATH=$PATH:$GOPATH/bin

#export GTK_THEME=Adwaita
#export PATH=$PATH:$HOME/eclipse/2025

export PATH=$PATH:~/localprefix/bin/
export PREFIX=~/localprefix

markdown() {
  pandoc $1 >/tmp/$1.html
  firefox /tmp/$1.html
}

camera() {
  mpv av://v4l2:/dev/video0 --profile=low-latency --untimed
}

seabuild() {
  docker run --rm -it -v $HOME/dev/seastar/:$HOME/dev/seastar -w $HOME/dev/seastar -t seastar-dev "$@"
}

cqlsh() {
  podman exec -it scylla cqlsh $@
}

pa() {
  for dir in */; do
    if [ -d "$dir/.git" ]; then
      (
        cd "$dir" || exit
        echo $dir: $(parse_git_branch)
      )
    fi
  done

  for dir in */; do
    if [ -d "$dir/.git" ]; then
      (
        cd "$dir" || exit
        git fetch
        branch=$(git symbolic-ref --short HEAD)
        git pull origin "$branch"
        git gc --auto
      ) &
    fi
  done

  wait
}

parse_git_branch() {
  git branch 2>/dev/null | /usr/bin/sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

eval "$(pyenv virtualenv-init -)"
eval "$(pyenv init -)"

# >>> mamba initialize >>>
# !! Contents within this block are managed by 'micromamba shell init' !!
export MAMBA_EXE='/home/izashchelkin/.local/bin/micromamba'
export MAMBA_ROOT_PREFIX='/home/izashchelkin/micromamba'
__mamba_setup="$("$MAMBA_EXE" shell hook --shell bash --root-prefix "$MAMBA_ROOT_PREFIX" 2>/dev/null)"
if [ $? -eq 0 ]; then
  eval "$__mamba_setup"
else
  alias micromamba="$MAMBA_EXE" # Fallback on help from micromamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<
