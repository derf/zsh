## vim:ft=zsh

: ${ZDIR:=${HOME}/packages/zsh/etc}
PS4='%b%u%s%k%F{cyan}%N%F{default}:%F{yellow}%D{%H%M-%S}%F{default}:%F{yellow}%i%F{default}│'
fpath=(${ZDIR}/functions ${ZDIR}/completions ${fpath})

# Additional zshenv settings from caretaker
[[ -r ${ZDIR}/../provided/env ]] && source ${ZDIR}/../provided/env

export EDITOR==vim
export MPD_HOST=mpd
export CALENDAR_DIR=${HOME}/stuff

export LESS='--silent --no-init --clear-screen --RAW-CONTROL-CHARS'\
' --quit-if-one-screen --ignore-case --tabs=5'

# Required for various scripts
export HOST
export COLUMNS
export LINES

export DEBFULLNAME='Birte Friesel'
export DEBEMAIL='derf@chaosdorf.de'

export PERLBREW_ROOT=${HOME}/var/perl5/perlbrew

if [[ -n ${commands[lesspipe]} ]] {
	export LESSOPEN='| lesspipe %s'
	export LESSCLOSE='lesspipe %s %s'
}

# local settings, not tracked with git
[[ -r ${ZDIR}/local-env ]] && source ${ZDIR}/local-env
