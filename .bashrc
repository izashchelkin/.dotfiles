#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export HISTSIZE=50000
export HISTFILESIZE=100000

shopt -s histappend

PROMPT_COMMAND='history -a; history -n'

export HISTCONTROL=ignoreboth:erasedups
export HISTTIMEFORMAT='%F %T  '

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
export CMAKE_GENERATOR=Ninja
export CMAKE_BUILD_PARALLEL_LEVEL=16

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

source ~/vulkansdk/setup-env.sh

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

#
# https://bbs.archlinux.org/viewtopic.php?id=146850
#

if [ ! -n "$FEED_BOOKMARKS" ]; then export FEED_BOOKMARKS=$HOME/.feed_bookmarks; fi
if [ ! -d "$FEED_BOOKMARKS" ]; then mkdir -p $FEED_BOOKMARKS; fi

feed() {
	if [ ! -d $FEED_BOOKMARKS ]; then mkdir $FEED_BOOKMARKS; fi

	if [ ! -n "$1" ]; then
		echo -e "\\n \\e[04mUsage\\e[00m\\n\\n   \\e[01;37m\$ feed \\e[01;31m<url>\\e[00m \\e[01;31m<new bookmark?>\\e[00m\\n\\n \\e[04mSee also\\e[00m\\n\\n   \\e[01;37m\$ deef\\e[00m\\n"
		return 1;
	fi

	local rss_source="$(curl --silent $1 | sed -e ':a;N;$!ba;s/\n/ /g')";

	if [ ! -n "$rss_source" ]; then
		echo "The feed is empty";
		return 1;
	fi

	# THE RSS PARSER
	# The characters "£, §" are used as metacharacters. They should not be encountered in a feed...
	echo -e "$(echo $rss_source | \
		sed -e 's/&amp;/\&/g
		s/&lt;\|&#60;/</g
		s/&gt;\|&#62;/>/g
		s/<\/a>/£/g
		s/href\=\"/§/g
		s/<title>/\\n\\n\\n   :: \\e[01;31m/g; s/<\/title>/\\e[00m ::\\n/g
		s/<link>/ [ \\e[01;36m/g; s/<\/link>/\\e[00m ]/g
		s/<description>/\\n\\n\\e[00;37m/g; s/<\/description>/\\e[00m\\n\\n/g
		s/<p\( [^>]*\)\?>\|<br\s*\/\?>/\n/g
		s/<b\( [^>]*\)\?>\|<strong\( [^>]*\)\?>/\\e[01;30m/g; s/<\/b>\|<\/strong>/\\e[00;37m/g
		s/<i\( [^>]*\)\?>\|<em\( [^>]*\)\?>/\\e[41;37m/g; s/<\/i>\|<\/em>/\\e[00;37m/g
		s/<u\( [^>]*\)\?>/\\e[4;37m/g; s/<\/u>/\\e[00;37m/g
		s/<code\( [^>]*\)\?>/\\e[00m/g; s/<\/code>/\\e[00;37m/g
		s/<a[^§]*§\([^\"]*\)\"[^>]*>\([^£]*\)[^£]*£/\\e[01;31m\2\\e[00;37m \\e[01;34m[\\e[00;37m \\e[04m\1\\e[00;37m\\e[01;34m ]\\e[00;37m/g
		s/<li\( [^>]*\)\?>/\n \\e[01;34m*\\e[00;37m /g
		s/<!\[CDATA\[\|\]\]>//g
		s/\|>\s*<//g
		s/ *<[^>]\+> */ /g
		s/[<>£§]//g')\n\n";
	# END OF THE RSS PARSER

	if [ -n "$2" ]; then
		echo "$1" > $FEED_BOOKMARKS/$2
		echo -e "\\n\\t\\e[01;37m==> \\e[01;31mBookmark saved as \\e[01;36m\\e[04m$2\\e[00m\\e[01;37m <==\\e[00m\\n"
	fi
}

deef() {
	if test -n "$1"; then
		if [ ! -r "$FEED_BOOKMARKS/$1" ]; then
			echo -e "\\n \\e[01;31mBookmark \\e[01;36m\\e[04m$1\\e[00m\\e[01;31m not found.\\e[00m\\n\\n \\e[04mType:\\e[00m\\n\\n   \\e[01;37m\$ deef\\e[00m (without arguments)\\n\\n to get the complete list of all currently saved bookmarks.\\n";
			return 1;
		fi
		local url="$(cat $FEED_BOOKMARKS/$1)";
		if [ ! -n "$url" ]; then
			echo "The bookmark is empty";
			return 1;
		fi
		echo -e "\\n\\t\\e[01;37m==> \\e[01;31m$url\\e[01;37m <==\\e[00m"
		feed "$url";
	else
		echo -e "\\n \\e[04mUsage\\e[00m\\n\\n   \\e[01;37m\$ deef \\e[01;31m<bookmark>\\e[00m\\n\\n \\e[04mCurrently saved bookmarks\\e[00m\\n";
		for i in $(find $FEED_BOOKMARKS -maxdepth 1 -type f);
			do echo -e "   \\e[01;36m\\e[04m$(basename $i)\\e[00m";
		done;
		echo -e "\\n \\e[04mSee also\\e[00m\\n\\n   \\e[01;37m\$ feed\\e[00m\\n";
	fi;
}

#
#
#

