if [ "x$__GIT_PROMPT_DIR" == "x" ]
then
  __GIT_PROMPT_DIR=$DOTFILES/bash/bash-git-prompt
fi

# Colors
# Reset
ResetColor="\[\033[0m\]"       # Text Reset

# Regular Colors
Red="\[\033[0;31m\]"          # Red
Yellow="\[\033[0;33m\]"       # Yellow
Blue="\[\033[0;34m\]"         # Blue
WHITE='\[\033[37m\]'

# Bold
BGreen="\[\033[1;32m\]"       # Green

# High Intensty
IBlack="\[\033[0;90m\]"       # Black

# Bold High Intensty
Magenta="\[\033[1;95m\]"     # Purple

# Various variables you might want for your PS1 prompt instead
User="$Green\u@$IWhite\h"
Time12a="\@"
PathShort="\w"

# Default values for the appearance of the prompt. Configure at will.
GIT_PROMPT_PREFIX="["
GIT_PROMPT_SUFFIX="]"
GIT_PROMPT_SEPARATOR="|"
GIT_PROMPT_BRANCH="${Magenta}"
GIT_PROMPT_STAGED="${Red}● "
GIT_PROMPT_CONFLICTS="${Red}✖ "
GIT_PROMPT_CHANGED="${Blue}✚ "
GIT_PROMPT_REMOTE=" "
GIT_PROMPT_UNTRACKED="…"
GIT_PROMPT_CLEAN="${BGreen}✔"

# PROMPT_START="$User:$Yellow$PathShort$ResetColor"
PROMPT_END="\n$IWhite\\$\[$ResetColor\] "

ROOT_PS1="\n\[$Red\]\u\[$IWhite\]@\[$Red\]\h(\!)\[$C_Off\]\[$Yellow\]:\w\[$C_Off\]"
USER_PS1="\n\[$Green\]\u\[$C_Off\]@\[$IWhite\]\h(\!)\[$C_Off\]\[$Yellow\]:\w\[$C_Off\]"

export SUDO_PS1=$ROOT_PS1
function am_i_root() {
	if (( $UID == 0 )); then
		export PROMPT_START=$ROOT_PS1
	else
		export PROMPT_START=$USER_PS1
	fi
}

function update_current_git_vars() {
    unset __CURRENT_GIT_STATUS
    local gitstatus="${__GIT_PROMPT_DIR}/gitstatus.py"
    
    _GIT_STATUS=$(python $gitstatus)
    __CURRENT_GIT_STATUS=($_GIT_STATUS)
	GIT_BRANCH=${__CURRENT_GIT_STATUS[0]}
	GIT_REMOTE=${__CURRENT_GIT_STATUS[1]}
    if [[ "." == "$GIT_REMOTE" ]]; then
		unset GIT_REMOTE
	fi
	GIT_STAGED=${__CURRENT_GIT_STATUS[2]}
	GIT_CONFLICTS=${__CURRENT_GIT_STATUS[3]}
	GIT_CHANGED=${__CURRENT_GIT_STATUS[4]}
	GIT_UNTRACKED=${__CURRENT_GIT_STATUS[5]}
	GIT_CLEAN=${__CURRENT_GIT_STATUS[6]}
}

function setGitPrompt() {
	update_current_git_vars
	set_virtualenv
	am_i_root

	if [ -n "$__CURRENT_GIT_STATUS" ]; then
	  STATUS=" $GIT_PROMPT_PREFIX$GIT_PROMPT_BRANCH$GIT_BRANCH$ResetColor"

	  if [ -n "$GIT_REMOTE" ]; then
		  STATUS="$STATUS$GIT_PROMPT_REMOTE$GIT_REMOTE$ResetColor"
	  fi

	  STATUS="$STATUS$GIT_PROMPT_SEPARATOR"
	  if [ "$GIT_STAGED" -ne "0" ]; then
		  STATUS="$STATUS$GIT_PROMPT_STAGED$GIT_STAGED$ResetColor"
	  fi

	  if [ "$GIT_CONFLICTS" -ne "0" ]; then
		  STATUS="$STATUS$GIT_PROMPT_CONFLICTS$GIT_CONFLICTS$ResetColor"
	  fi
	  if [ "$GIT_CHANGED" -ne "0" ]; then
		  STATUS="$STATUS$GIT_PROMPT_CHANGED$GIT_CHANGED$ResetColor"
	  fi
	  if [ "$GIT_UNTRACKED" -ne "0" ]; then
		  STATUS="$STATUS$GIT_PROMPT_UNTRACKED$GIT_UNTRACKED$ResetColor"
	  fi
	  if [ "$GIT_CLEAN" -eq "1" ]; then
		  STATUS="$STATUS$GIT_PROMPT_CLEAN"
	  fi
	  STATUS="$STATUS$ResetColor$GIT_PROMPT_SUFFIX"

	  PS1="$PYTHON_VIRTUALENV$PROMPT_START$STATUS$PROMPT_END"
	else
	  PS1="$PROMPT_START$PROMPT_END"
	fi
}

# Determine active Python virtualenv details.
function set_virtualenv () {
  if test -z "$VIRTUAL_ENV" ; then
      PYTHON_VIRTUALENV=""
  else
      PYTHON_VIRTUALENV="${BLUE}(`basename \"$VIRTUAL_ENV\"`)${ResetColor} "
  fi
}

export PROMPT_COMMAND=setGitPrompt
