# vim:set expandtab shiftwidth=4 filetype=zsh:
# SPDX-License-Identifier: GPL-3.0-only

#
#
# ~xxdorothy/.config.git
# ::: :/mise/shell/cd.zsh
#
#

# Sourced by the mise enter hook; undone by the leave hook.
#
# A mise task moves this shell by writing a directory to $XXDY_SHELL_CD_FILE;
# the next prompt changes into it. Worktrunk tasks receive the file as
# WORKTRUNK_DIRECTIVE_CD_FILE, the channel wt's own shell integration uses.

autoload -Uz add-zsh-hook

# One file per shell. The marker is not exported, so a nested shell, which
# inherits XXDY_SHELL_CD_FILE, makes its own rather than moving its parent.
if (( ! ${+_xxdy_shell_cd_owned} )); then
    typeset -g  _xxdy_shell_cd_owned=1
    typeset -gx XXDY_SHELL_CD_FILE=$(mktemp -t xxdy-cd.XXXXXX)
fi

_xxdy_shell_cd() {
    local target
    if [[ -s $XXDY_SHELL_CD_FILE ]]; then
        target=$(<$XXDY_SHELL_CD_FILE)
        : >| $XXDY_SHELL_CD_FILE
        [[ -d $target ]] && builtin cd -- $target
    fi
    # A task removed this directory without naming another: climb out.
    if [[ ! -d $PWD ]]; then
        target=$PWD
        while [[ ! -d $target ]]; do target=${target:h}; done
        builtin cd -- $target
    fi
}

_xxdy_shell_cd_unload() {
    add-zsh-hook -d precmd  _xxdy_shell_cd
    add-zsh-hook -d zshexit _xxdy_shell_cd_unload
    rm -f -- $XXDY_SHELL_CD_FILE
    unset XXDY_SHELL_CD_FILE _xxdy_shell_cd_owned
    unfunction _xxdy_shell_cd _xxdy_shell_cd_unload
}

add-zsh-hook precmd  _xxdy_shell_cd
add-zsh-hook zshexit _xxdy_shell_cd_unload
