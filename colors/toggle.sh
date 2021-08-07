#!/usr/bin/env bash

default_theme="light"

TMUX_COLORS_CFG_DIR=~/.tmux/colors
TMUX_COLORS_THEME="@colors-theme"

VIM_COLORS_CFG_DIR=~/.vim/colors

make_tmux_color_link() {
  local theme="$1"
  cd "${TMUX_COLORS_CFG_DIR}" && \
    ln -nfs tmuxcolors-${theme}.conf tmuxcolors.conf && \
    tmux source-file "${TMUX_COLORS_CFG_DIR}/tmuxcolors.conf"
}

make_vim_color_link() {
  local theme="$1"
  cd "${VIM_COLORS_CFG_DIR}" && \
    ln -nfs background-${theme}.vim background.vim
}

get_tmux_option() {
	local option="$1"
	local default_value="$2"
	local option_value="$(tmux show-option -gqv "$option")"
    echo "${option_value:-$default_value}"
}

main() {

  # Get current theme, default to light (dark because value is toggled)
  COLOR_THEME=$(get_tmux_option "$TMUX_COLORS_THEME" "dark" )

  # Toggle the current color
  case "$COLOR_THEME" in
    "light") COLOR_THEME="dark";;
    "dark") COLOR_THEME="light";;
  esac

  make_tmux_color_link "$COLOR_THEME"
  tmux set-option -g @colors-theme "$COLOR_THEME"

  # alacritty
  yq e '.colors alias="'$COLOR_THEME'"' -i ~/.config/alacritty/alacritty.yml

  # vim
  make_vim_color_link "$COLOR_THEME"

  # bat
  export BAT_THEME="Solarized (${COLOR_THEME})"
  tmux setenv -g -t 0 BAT_THEME "Solarized (${COLOR_THEME})"
}

main || exit 1

# vim: set ft=bash:
