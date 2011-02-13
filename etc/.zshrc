## vim:ft=zsh:foldmethod=marker
## Copyright (c) 2008, 2009 by Daniel Friesel <derf@derf.homelinux.org>
## Licence:
##   0. You just DO WHAT THE FUCK YOU WANT TO.
##
## http://derf.homelinux.org/git/zsh/plain/etc/.zshrc
## see also: http://derf.homelinux.org/git/zsh/tree/etc

# {{{ OS Detection

[[ -f /etc/debian_version ]] && distro=debian

# }}}
# {{{ Startup infos

function zrc_info {
	print -P "%F{red}>>%F{default} ${*}"
}

# }}}
# {{{ Options

setopt auto_pushd pushd_ignore_dups pushd_minus pushd_silent
setopt auto_cd

setopt transient_rprompt

setopt list_packed

setopt extended_glob

unsetopt bang_hist

setopt hist_ignore_dups

setopt correct

# greedy is more like dvorak than qwerty...
setopt dvorak
unsetopt flow_control
setopt rc_quotes

unsetopt beep

# }}}
# {{{ Shell parameters

## parameters which are only important for interactive shells.
## For application-related parameters, see .zshenv

if [[ -d ~/var/cache/zsh ]] {
	ZCACHEDIR=~/var/cache/zsh
} else {
	mkdir -p ~/.zsh-cache
	ZCACHEDIR=~/.zsh-cache
}

HISTFILE=${ZCACHEDIR}/history
HISTSIZE=100000
SAVEHIST=${HISTSIZE}

DIRSTACKSIZE=20

# Use the full terminal size for listings
LISTMAX=0

TIMEFMT='%J (%P)  -  %*E real, %*U user, %*S system'

if (( EUID != 0)) {
	path+=(/sbin /usr/sbin /usr/local/sbin)
}

export MAKEFLAGS=j$(grep -c '^processor' /proc/cpuinfo)

if [[ -e /sys/class/net/vpn ]] {
	export http_proxy='http://10.200.200.2:8080/'
}

if [[ -n ${commands[clang]} ]] {
	export CC=clang
}

typeset -U path
path=(~/bin ${path})

# Add manuals from caretaker to manpath
if [[ ${distro} == debian ]] {
	export MANPATH=/usr/share/man:/usr/local/share/man
	MANPATH+=":${HOME}/packages/.collected/man"
}

# }}}
# {{{ MIME parameters

mime_archive=(
	7z ace arj bz bz2 cpio deb dz gz jar lzh lzma rar rpm rz svgz
	tar taz tbz2 tgz tz xz z Z zip zoo
)
mime_audio=(
	aif aifc aiff amr amr au awb awb axa flac gsm kar m3u m3u m4a mid midi
	mp2 mp3 mpega mpga oga ogg pls ra ra ram rm sd2 sid snd spx wav wax wma
)
mime_document=(pdf ps)
mime_image=(
	art bmp cdr cdt cpt cr2 crw djv djvu erf gif ico ief jng jpe jpeg jpg nef
	orf pat pbm pcx pgm png pnm ppm psd ras rgb svg svgz tif tiff wbmp xbm
	xpm xwd
)
mime_video=(
	3gp asf asx avi axv dif divx dl dv fli flv gl lsf lsx m2t mkv mng mov
	movie mp4 mpe mpeg mpg mpv mxu ogm ogv qt rmvb ts webm wm wmv wmx wvx
)

# }}}
# {{{ ls-colors (partially based on MIME)

#        default:file :dirctory:  link  :  pipe  : socket
LS_COLORS="no=00:fi=00:di=01;37:ln=01;36:pi=40;33:so=01;35"

#            door    : block dev : char dev  :broken link: setuid
LS_COLORS+=":do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41"

#            setgid  : +t,o+w :  o+w   : sticky : executable
LS_COLORS+=":sg=30;43:tw=30;42:ow=34;42:st=37;44:ex=01;32"

LS_COLORS+=:${(j/:/):-"*."${^mime_archive}"=04;31"}
LS_COLORS+=:${(j/:/):-"*."${^mime_audio}"=04;36"}
LS_COLORS+=:${(j/:/):-"*."${^mime_document}"=04"}
LS_COLORS+=:${(j/:/):-"*."${^mime_image}"=04;33"}
LS_COLORS+=:${(j/:/):-"*."${^mime_video}"=04;32"}

export LS_COLORS

# }}}
# {{{ Functions

autoload -U compinit
autoload zargs zmv

if [[ -e ${ZDIR}/functions ]] {
	autoload ${ZDIR}/functions/*(:t)
} else {
	# No cool extra stuff
	zrc_info "Running in standalone mode"
	# rtab is tracked in functions/, so it may not be present everywhere.
	# However, the prompt assumes the presence of a 'rtab' function.
	function rtab {
		print -P %~
	}
}


# This all belongs into the prompt, but since it only changes
# when changing directories, it's more efficient to do it here
function chpwd {
	psvar[1]=$(dirinfo)
	psvar[2]=$(rtab)
}

function dirinfo {
	typeset string

	[[ -r .todo ]] && string+='todo '
	[[ -f .fehindex.jpg ]] && string+='feh '
	[[ -d .hg ]] && string+='hg '
	[[ -d .git ]] && string+='git '
	[[ -d .svn ]] && string+='svn '
	[[ -f Makefile || -f makefile ]] && string+='make '

	echo ${string% }
}

function xhashd {
	typeset directory=${~1#*\=} name=${1%%\=*}

	if [[ -d ${directory} ]] {
		hash -d ${name}=${directory}
	}
}

function Status Start Stop Restart Reload {
	typeset script
	for script in ${*}; {
		sudo /etc/init.d/${script} ${0:l}
	}
}

# }}}
# {{{ ZLE

autoload -U url-quote-magic

zle -N self-insert url-quote-magic

# }}}
# {{{ Prompt

# psvar[1] = directory info
# psvar[2] = rtab (current directory)
# (both set by the chpwd function)

typeset -A ps rps

ps=(
	host   "%F{yellow}%m"
	dir    "%F{default}%30<…<%2v%>>"
	sign   "%(!.%F{red}.%F{green})%(?.%(!.#.>).%?)%F{default}"
)

rps=(
	start    "%(1V.%F{yellow}["
	dirinfo  "%F{default}%1v"
	end      "%(1V.%F{yellow}]%F{default}.)"
)

PS1="${ps[host]} ${ps[dir]} ${ps[sign]} "

RPS1="${rps[start]}${rps[dirinfo]}${rps[end]}"

unset ps rps

zstyle ':prompt:rtab' fish yes
zstyle ':prompt:rtab' nameddirs yes


# }}}
# {{{ Named directories

xhashd code=~/var/code
xhashd vcs=~/var/svn
xhashd web=~/public_html

# }}}
# {{{ Keys

bindkey -e
[[ -z ${terminfo[kdch1]} ]] || bindkey -M emacs ${terminfo[kdch1]} \
	delete-char
[[ -z ${terminfo[khome]} ]] || bindkey -M emacs ${terminfo[khome]} \
	beginning-of-line
[[ -z ${terminfo[kend]}  ]] || bindkey -M emacs ${terminfo[kend]} \
	end-of-line

# }}}
# {{{ Aliases
# {{{ Suffix

typeset -A alias_apps
alias_apps=(
	archive    extract
	audio      mplayer
	document   apvlv
	image      feh
	video      mplayer
)

for meta in ${parameters[(I)mime_*]#mime_}; {
	for format in $(eval echo '$'mime_${meta}); {
		alias -s ${format}=${alias_apps[$meta]}
	}
}

unset filetypes meta format alias_apps

# }}}
# {{{ Defaults

# To evade these defaults, use '=command' instead of 'command'

alias grep='grep --color=auto'
alias egrep='grep -E'
alias fgrep='grep -F'
alias bzgrep='bzgrep --color=auto'
alias zgrep='zgrep --color=auto'


alias df='df -h'

alias du='du -shH'

alias ls='ls -h --color=auto'

[[ -n ${commands[bsdtar]} ]] && alias tar=bsdtar

## enable alias expansion
alias exec='exec '
alias sudo='sudo '

alias netstat='sudo netstat --program --all --tcp --extend'

alias svstat='sudo svstat /etc/service/*'

alias bc='bc -l'

alias fbi='fbi -readahead'

alias cp='cp -i'
alias mv='mv -i'

alias pmount='pmount -A'

alias exifprobe='exifprobe -Rc'

alias find='noglob find'

alias man='man -a'

# ps -C foo is better than ps aux | fgrep foo ;-)
alias ps='ps -F'

alias todo='noglob todo -f +children'

alias vim='vim -p'

# }}}
# {{{ Font

alias font-present='echo -en '\
'"\033]50;-*-terminus-medium-*-*-*-*-320-*-*-*-*-*-*\007"'

alias font-default='echo -en '\
'"\033]50;-misc-fixed-medium-r-semicondensed--13-*-*-*-*-*-iso10646-1\007"'

alias font-t='echo -en '\
'"\033]50;-*-terminus-medium-*-*-*-*-150-*-*-*-*-*-*\007"'

# }}}
# {{{ Global

# global aliases are slightly evil, but (usually) not messy
alias -g EG='|egrep'
alias -g FG='|fgrep'
alias -g G='|grep'
alias -g H='|head'
alias -g L='|less'
alias -g T='|tail'

# }}}
# {{{ Loop me

alias allf='for i in *(.);'
alias alld='for i in *(/);'
alias alle='for i in *(*);'
alias alll='for i in *(@);'
alias all='for i in *;'

alias allfr='for i in **/*(.);'
alias alldr='for i in **/*(/);'
alias aller='for i in **/*(*);'
alias alllr='for i in **/*(@);'
alias allr='for i in **/*;'

# }}}
# {{{ Misc

alias dent='twidge update'

alias dent-cccd='twidge -c ~/.twidgerc.chaosdorf update'

alias dua='du --apparent-size'

alias lasth='last | head -$((LINES-1))'

alias fbif='fbi -a'
alias fbij='fbi -a -u'

alias icq='dtach -A ~/.dtach.ysm ysm'
alias irc='dtach -A ~/.dtach.irssi irssi'
alias jabber='dtach -A ~/.dtach.mcabber mcabber'
alias safe='dtach -c /tmp/.dtach.$$'

for i in ~/var/gtd/*(.N); {
	alias gtd-${i:t}='todo --database '${i}
}

alias lsi='feh --list'
alias lst='tar -tvf'
alias lsz='unzip -l'

alias lssh='ssh -C -o CompressionLevel=9'

alias mate='decrement ~/stuff/$(cat /tmp/.location)/mateguthaben'

alias nb='newsbeuter'
alias nbr='newsbeuter -r'

alias rd='rmdir'

alias rebuild='perl Build.PL && ./Build && ./Build test && sudo ./Build install'
alias remake='make clean; make && sudo make install'

alias rsync-serve="rsync --daemon --port=10873 --no-detach --config=/dev/stdin"\
" --log-file=/dev/stdout -v <<< $'[.]\n\tpath = .\n\tuse chroot = no'"

alias scanto='convert =(sudo scanimage -p -d hp4200:libusb:002:002)'

alias x='unsetopt bg_nice; startx &! exit'

alias xxz='xz -v -9 -M 800M'

# }}}
if [[ ${distro} == debian ]] { #{{{

	alias acse='apt-cache search'
	alias afse='apt-file search'
	alias apse='aptitude search'

	alias acp='apt-cache policy'
	alias acsh='apt-cache show'
	alias afsh='apt-file show'
	alias apsh='aptitude show'
	alias dps='dpkg --status'

	alias agu='sudo apt-get update'
	alias apu='sudo aptitude update'

	alias ags='sudo apt-get upgrade'
	alias agf='sudo apt-get dist-upgrade'
	alias aps='sudo aptitude safe-upgrade'
	alias apf='sudo aptitude full-upgrade'

	alias agi='sudo apt-get install'
	alias api='sudo aptitude install'
	alias dpi='sudo dpkg --install'

	alias agc='sudo apt-get clean'
	alias apc='sudo aptitude clean'

	alias agar='sudo apt-get autoremove'
	alias agp='sudo apt-get purge'
	alias agr='sudo apt-get remove'
	alias dpp='sudo dpkg --purge'
	alias dpr='sudo dpkg --remove'

	alias agsrc='apt-get source'

	alias dprc='sudo dpkg-reconfigure'

} #}}}
if [[ ${HOST} == aneurysm ]] { #{{{

	while read mdir discard; do

		alias mutt-${${mdir#.}//\//-}="mutt -f ${HOME}/Maildir/${mdir}"

	done < Maildir/maildirs
# }}}
} else { #{{{

	alias icli='ssh aneurysm icli'

} #}}}
if [[ -e /tmp/.x-started ]] { #{{{

	alias 4d=4chan-dl
	alias 4v=4chan-view

	alias feh='feh --quiet --verbose --action8 "nrm '\'%f\'\"

	# Alias structure:
	# feh[theme][recursive?][slide-delay?]
	# theme = [f]ullscreen | [i]ndex | [j]ust | [t]humbnail
	# recursive: r for recursive, nothing otherwise
	# slide-delay:
	#     none   - no slideshow
	#     x      - slideshow, seconds will be specified on commandline
	#              (like "fehfrx 7 .")
	# The themes are defined in ~/.fehrc
	alias fehf='feh -Tfs'
	alias fehfr='feh -Tfs --recursive'
	alias fehi='feh .fehindex.jpg'
	alias fehj='feh -Trfs'
	alias fehjr='feh -Trfs --recursive'
	alias fehjx='feh -Trfs --slideshow-delay'
	alias fehfx='feh -Tfs --slideshow-delay'
	alias fehjrx='feh -Trfs --recursive --slideshow-delay'
	alias fehfrx='feh -Tfs --recursive --slideshow-delay'
	alias feht='feh -Tthumb_s'
	alias fehtr='feh -Tthumb_s --recursive'
	alias fehtb='feh -Tthumb_b'
	alias fehtbr='feh -Tthumb_b --recursive'
	alias fehtn='feh -Tthumb_s_nt'
	alias fehtnr='feh -Tthumb_s_nt --recursive'
	alias fehtnb='feh -Tthumb_b_nt'
	alias fehtnbr='feh -Tthumb_b_nt --recursive'

	alias putscreen='put $(screenshot)'

	alias lmplayer='mplayer -vfm ffmpeg -lavdopts lowres=1:fast:skiploopfilter=all'
} #}}}

# }}}
# {{{ Misc

mesg n
if ((UID)) {
	umask 077
} else {
	umask 002
}
chpwd

# Show infos if requested (.xinitrc)

if ((SHOW_INFO)) {
	${ZDIR}/../helpers/info
}

# }}}
# {{{ Includes

if [[ -e ${ZDIR}/../provided/includes ]] {
	source ${ZDIR}/../provided/includes
}

if [[ -e ${ZDIR}/local ]] {
	source ${ZDIR}/local
}

[[ -n ${commands[envstore]} ]] && eval $(envstore eval)

# }}}
# {{{ Completion

zstyle ':completion:*' cache-path ${ZCACHEDIR}
zstyle ':completion:*' use-cache true

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

zstyle ':completion:*' menu select=1

# Complete uppercase chars with lowercase ones, spaces with _,
# start completion somewhere else than the beginning of the word if neccessary
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z} m:_=\\\ ' '+ l:|=* r:|=*'

zstyle ':completion:*' verbose true

zstyle ':completion:*:descriptions' format '· %d ·'
zstyle ':completion:*:messages'     format '· %d ·'
zstyle ':completion:*:corrections'  format '· %d ·'
zstyle ':completion:*:warnings'     format '%F{red}no match:%F{default} %d'

zstyle ':completion:*' group-name ''

# Force menu completion since the input is just a stupid number
zstyle ':completion:*:*:kill:*' menu yes
zstyle ':completion:*:*:(todo|td*):*:items' menu yes

zstyle ':completion:*:*:vi(m|):*' ignored-patterns \
	'a.out|*.o'

# source: http://madism.org/~madcoder/dotfiles/zsh/40_completion
zstyle ':completion:*:processes' command \
	'ps -au${USER} -o pid,time,cmd|grep -v "ps -au${USER} -o pid,time,cmd"'

zstyle ':completion:*:*:kill:*:processes' list-colors \
	'=(#b) #([0-9]#)[ 0-9:]#([^ ]#)*=01;30=01;31=01;38'

zstyle ':completion:*:manuals'    separate-sections true
zstyle ':completion:*:manuals.*'  insert-sections   true

# ${hosts} is set from the hosts package
zstyle ':completion:*' hosts ${(k)hosts}

[[ -e ${ZCACHEDIR}/compdump ]] || zrc_info "Creating completion cache"
compinit -C -d ${ZCACHEDIR}/compdump

compdef _hosts sshmount
compdef _functions reload

# }}}
# {{{ Cleanup

unfunction zrc_info
unset system distro
unset -m 'mime_*'

# }}}
