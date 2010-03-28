## vim:ft=zsh
function pr_info {
	print -P "%F{cyan}>>%F{default} $*"
}

echo

pr_info "This is %F{cyan}$(uname -srm)%F{default} on %F{cyan}%y%F{default}"
[[ -r /etc/gentoo-release ]] && pr_info "Running %F{cyan}Gentoo%F{default} ${$(cat /etc/gentoo-release)#(#i)gentoo }"
[[ -r /etc/debian_version ]] && pr_info "Running %F{cyan}Debian%F{default} $(cat /etc/debian_version)"
[[ -r /etc/arch-release   ]] && pr_info "Running %F{cyan}Arch%F{default}"
[[ -r /etc/redhat-release ]] && pr_info "Running %F{cyan}Redhat%F{default}"

echo

[[ -n $(echo Maildir/new/*(N)) ]] && pr_info "You have mail!"
[[ -r $ZDIR/local-profile ]] && source $ZDIR/local-profile
[[ -r $ZDIR/hosts/profile-$HOST ]] && source $ZDIR/hosts/profile-$HOST

unfunction pr_info
