file_manager() {
	# Help Manual
	read -r -d '' HELP <<EOF
Zsh-File-Manager Manual

Base on "zsh" using "fzf", the File-Manager is a lightweight tool that incorporates "exa" and "bat" for enhanced functionality.

Binding keys:

C-u                 preview window page up
C-d                 preview window page down
C-s                 preview window horizontally
C-v                 preview window vertically
C-k, C-p, up        up
C-j, C-n, down      down
C-h, left           back "cd .."
C-l, right enter    selected
                      if it is a directory, it enters it.
                      if it is a file, it adds the filename to the terminal BUFFER.
pgup                page up
pgdn                page down
C-c, C-f, C-g       quit

About fallback:

If "exa" is not installed, it will use "ls" as a fallback.
If "bat" is not installed, it will use "cat" as a fallback.
EOF

  # check fzf
  if ! (command -v fzf &>/dev/null); then
    echo 'file-manager: command not found "fzf". See "https://github.com/junegunn/fzf"'
    BUFFER=""
    zle accept-line
    return 1
  fi
  local fzf_ver=$(fzf --version | awk -F'[. ]' '{ print $2 }')

	setopt localoptions pipefail no_aliases 2>/dev/null

	# commands
	local ops='9'
	local ls_dir='exa -bglHh --all --all --color=always'
	local cat_file='bat -pn --color=always'

	# commands fallback
	if ! (command -v exa &>/dev/null); then
		ls_dir="ls -al --color=yes"
	fi
	if ! (command -v bat &>/dev/null); then
		cat_file='batcat'
	fi
	if ! (command -v batcat &>/dev/null); then
		cat_file='cat'
	fi

	#tmp file
	local TMP='/tmp/file-manager'
	mkdir -p "$TMP"

	# debug log
	dbg() {
		return
		echo "$@" >>$TMP/dbg.log
	}

	# preview_window config
	local PREVIEW_WINDOW_H='down,55%,wrap'
	local PREVIEW_WINDOW_V='right,55%,wrap'
	local TMP_PREVIEW_WINDOW="$TMP/preview_window"
	if [ ! -f $TMP_PREVIEW_WINDOW ]; then
		echo "$PREVIEW_WINDOW_V" >$TMP_PREVIEW_WINDOW
	fi

	# main loop
	while :; do

    local border='--border=top'
    local border_label="--border-label=| $PWD |"
		# show "x -> y" for link file
    local bind_focus_transform_preview_label="--bind=focus:transform-preview-label( echo '|' \$( if [ ! -z {$(($ops + 1))} ]; then echo {$ops} {$(($ops + 1))} {$(($ops + 2))}; else echo {$ops}; fi ) '|' )"
    local color="--color=label:#5555FF:200"
    local header='--header=Press ? for help'
		local ctrl_s_preview_window="--bind=ctrl-s:change-preview-window(down)+execute(echo $PREVIEW_WINDOW_H>$TMP_PREVIEW_WINDOW)"
		local ctrl_v_preview_window="--bind=ctrl-v:change-preview-window(right)+execute(echo $PREVIEW_WINDOW_V>$TMP_PREVIEW_WINDOW)"
		local ctrl_u_preview_page_up='--bind=ctrl-u:preview-half-page-up'
		local ctrl_d_preview_page_down='--bind=ctrl-d:preview-half-page-down'
		local q_help="--bind=?:preview(echo '$HELP')"

    # old fzf
    if (($fzf_ver < 30)); then
      border_label=''
      bind_focus_transform_preview_label=''
      color=''
      header="--header=Press ? for help; [ $PWD ]"
    fi
    if (($fzf_ver < 24)); then
      border=''
      ctrl_s_preview_window=''
      ctrl_v_preview_window=''
      ctrl_u_preview_page_up=''
      ctrl_d_preview_page_down=''
      q_help=''
      header="--header=Recommanded upgrade 'fzf' to > 0.30; [ $PWD ]"
    fi

		local fzf_args=(
			+m
			--ansi
			--reverse
			--nth=9
			--height=60%
      $border
			$border_label

			--preview=" if [ -f {$ops} ]; then $cat_file {$ops}; else $ls_dir {$ops}; fi "
			--preview-window="$(cat $TMP_PREVIEW_WINDOW)"
			$color

			--bind='change:top'
			$ctrl_s_preview_window
			$ctrl_v_preview_window
			$bind_focus_transform_preview_label
      $ctrl_u_preview_page_up
      $ctrl_d_preview_page_down
			--bind='ctrl-f:abort'
			# go to ..
			--bind='ctrl-h:execute(echo "//BACK//")+abort'
			--bind='left:execute(echo "//BACK//")+abort'
			# selected
			--bind='ctrl-l:accept'
			--bind='right:accept'

			--bind='ctrl-z:ignore'
      $q_help
			$header
		)
		local selected=$(eval "$ls_dir" | sed 1,2d | fzf "${fzf_args[@]}")
		dbg "selected: $selected"

		# quit
		if [ -z "$selected" ]; then
			dbg "quit: $selected"
			BUFFER=""
			zle reset-prompt
			return 0
		# back
		elif [[ "$selected" == '//BACK//' ]]; then
			selected='..'
		# get selected value
		else
			selected=$(echo $selected | awk "{ print \$$ops }")
		fi
		dbg "SELECTED: $selected"

		# selected file
		# push it to BUFFER
		if [[ -f "$selected" ]]; then
			dbg "push: $selected"
			zle reset-prompt
			BUFFER="$selected"
			return 0
		fi

		# selected directory
		# cd to dir
		dbg "cd: $selected"
		BUFFER="builtin cd -- ${selected}"
		builtin cd $selected
		# zle accept-line
		zle redisplay
	done
}

autoload -Uz file_manager
zle -N file_manager
bindkey '^F' file_manager

