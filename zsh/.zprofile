#
# ~/.zprofile
#

[[ -f ~/.zshrc ]] && . ~/.zshrc
# [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx

PANEL_FIFO=/tmp/panel-fifo
PANEL_HEIGHT=24
PANEL_FONT_FAMILY="-*-terminus-medium-r-normal-*-12-*-*-*-c-*-*-1"
export PANEL_FIFO PANEL_HEIGHT PANEL_FONT_FAMILY
export PATH=$PATH:/home/vga/.config/bspwm/panel
