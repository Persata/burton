#!/usr/bin/env zsh

setopt prompt_subst

autoload -U add-zsh-hook
autoload -Uz vcs_info

BURON_GIT_CLEAN_SYMBOL=$'\u2714'
BURTON_GIT_DIRTY_SYMBOL=$'\u2718'

BURTON_GIT_UNPUSHED_SYMBOL="⇡"
BURTON_GIT_UNPULLED_SYMBOL="⇣"

# TODO - Status when no remote branch exists, tick?

function prompt_burton_precmd {
  local branch_format="${_prompt_burton_colors[6]}%b%f"
  local action_format="${_prompt_burton_colors[6]}%b%f ${_prompt_burton_colors[2]}(%a)%f"

  if [[ -z "$(git status --porcelain --ignore-submodules 2> /dev/null)" ]]; then
    branch_format+=" ${_prompt_burton_colors[3]}${BURON_GIT_CLEAN_SYMBOL}%f"
    action_format+=" ${_prompt_burton_colors[3]}${BURON_GIT_CLEAN_SYMBOL}%f"
  else
    branch_format+=" ${_prompt_burton_colors[5]}${BURTON_GIT_DIRTY_SYMBOL}%f"
    action_format+=" ${_prompt_burton_colors[5]}${BURTON_GIT_DIRTY_SYMBOL}%f"
  fi

  local git_local=$(command git rev-parse @ 2> /dev/null)
  local git_remote=$(command git rev-parse @{u} 2> /dev/null)
  local git_base=$(command git merge-base @ @{u} 2> /dev/null)

  # First check that we have a remote
  if ! [[ ${git_remote} = "" ]]; then
    if [[ ${git_local} = ${git_base} ]]; then
      branch_format+=" ${_prompt_burton_colors[4]}$BURTON_GIT_UNPULLED_SYMBOL%f"
    elif [[ ${git_remote} = ${git_base} ]]; then
      branch_format+=" ${_prompt_burton_colors[4]}$BURTON_GIT_UNPUSHED_SYMBOL%f"
    else
      branch_format+=" ${_prompt_burton_colors[4]}$BURTON_GIT_UNPULLED_SYMBOL%f ${_prompt_burton_colors[4]}$BURTON_GIT_UNPUSHED_SYMBOL%f"
    fi
  fi

  zstyle ':vcs_info:*:prompt:*' formats "on ${branch_format}"
  zstyle ':vcs_info:*:prompt:*' actionformats "on ${action_format}"

  vcs_info 'prompt'
}

function prompt_burton_setup {
  setopt LOCAL_OPTIONS
  unsetopt XTRACE KSH_ARRAYS
  prompt_opts=(cr percent sp subst)

  # Load required functions.
  autoload -Uz add-zsh-hook
  autoload -Uz vcs_info

  # Add hook for calling vcs_info before each command.
  add-zsh-hook precmd prompt_burton_precmd

  # Use extended color pallete if available.
  if [[ $TERM = *256color* || $TERM = *rxvt* ]]; then
    _prompt_burton_colors=(
      "%F{201}" # 1 - Hot Pink
      "%F{2}" # 2 - Dark Green
      "%F{83}" # 3 - Light Green
      "%F{87}" # 4 - Light Blue
      "%F{196}" # 5 - Red
      "%F{129}" # 6 - Dark Purple
    )
  else
    _prompt_burton_colors=(
      "%F{magenta}"
      "%F{green}"
      "%F{cyan}"
      "%F{blue}"
      "%F{red}"
      "%F{magenta}"
    )
  fi

  # Set vcs_info parameters.
  zstyle ':vcs_info:*' enable bzr git hg svn
  zstyle ':vcs_info:*:prompt:*' check-for-changes true
  zstyle ':vcs_info:*:prompt:*' nvcsformats ""

  # Define prompts.
  PROMPT="
 ${_prompt_burton_colors[1]}%n%f @ ${_prompt_burton_colors[2]}%m%f in ${_prompt_burton_colors[3]}%~%f "'${vcs_info_msg_0_}'"
 %(?.${_prompt_burton_colors[4]}λ.${_prompt_burton_colors[5]}λ)%f "

  RPROMPT=''
}

prompt_burton_setup "$@"
