## vim:ft=zsh
function pr_info {
	print -P "%F{cyan}>>%F{default} ${*}"
}

echo

pr_info "This is %F{cyan}$(uname -srm)%F{default} on %F{cyan}%y%F{default}"

[[ -r /etc/gentoo-release ]] && pr_info 'Running %F{cyan}Gentoo%F{default}' \
	${$(cat /etc/gentoo-release)#(#i)gentoo }

[[ -r /etc/debian_version ]] && pr_info 'Running %F{cyan}Debian%F{default}' \
	$(cat /etc/debian_version)

[[ -r /etc/arch-release   ]] && pr_info 'Running %F{cyan}Arch%F{default}'
[[ -r /etc/redhat-release ]] && pr_info 'Running %F{cyan}Redhat%F{default}'

echo

function {
	typeset -a new_mail

	setopt local_options
	setopt hist_subst_pattern
	setopt extended_glob

	new_mail=(~/Maildir/**/new~*/.(spam|Trash)*(DFN:h:s/*\\/Maildir\\/./))

	if (( $#new_mail )); then
		pr_info "Unread mail in: ${(j(, ))new_mail}"
	fi
}

[[ -r ${ZDIR}/local-profile ]] && source ${ZDIR}/local-profile

if [[ ${HOST} == (carbon|descent|illusion|saviour) && -z ${SSH_CONNECTION} && \
	! -e /tmp/.x-started ]] \
{
	touch /tmp/.x-started
	unsetopt bg_nice
	xinit /home/derf/.xinitrc -- /etc/X11/xinit/xserverrc :0 -auth \
		$(mktemp --tmpdir serverauth.XXXXXXXXXX) &! exit
}

unfunction pr_info
