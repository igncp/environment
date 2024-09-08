#!/usr/bin/env bash

provision_get_ps1() {
  ANSI_COLOR_BLUE="\x1b[0;34m"
  ANSI_COLOR_GREEN="\x1b[0;32m"
  ANSI_COLOR_YELLOW="\x1b[0;33m"
  ANSI_COLOR_MAGENTA="\x1b[0;35m"
  ANSI_COLOR_RED="\x1b[0;31m"
  ANSI_COLOR_RESET="\x1b[0;0m"

  IS_BASH=$(echo "$BASH_VERSION" | grep -qE '^[0-9]' && echo 1 || echo 0)

  NIX_PREFIX=""
  if [ -n "$CD_INTO_NIX" ] || [ -n "$IN_NIX_SHELL" ]; then
    NIX_PREFIX=" (NIX)"
  fi

  get_tmux_window_index() {
    if [ -z "$TMUX" ]; then return; fi

    RAW_INDEX=$(tmux display-message -p "#I" || true)

    if [ -z "$RAW_INDEX" ]; then return; fi

    tmux display-message -p "#I" | tr -d '\n' || true
  }

  # https://miro.medium.com/max/4800/1*Q4WxN-bh4Exk8ULhwSexGQ.png
  translate_color_to_ansi() {
    case $1 in
    "green")
      echo "$ANSI_COLOR_GREEN"
      ;;
    "yellow")
      echo "$ANSI_COLOR_YELLOW"
      ;;
    "magenta")
      echo "$ANSI_COLOR_MAGENTA"
      ;;
    "red")
      echo "$ANSI_COLOR_RED"
      ;;
    *)
      echo "$ANSI_COLOR_RESET"
      ;;
    esac
  }

  get_ssh_notice() {
    SSH_NOTICE_COLOR=$(cat "$HOME/development/environment/project/.config/ssh-notice-color" || true)
    if [ -z "$SSH_NOTICE_COLOR" ]; then
      SSH_NOTICE_COLOR="cyan"
    fi

    SSH_NOTICE=""
    if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] || [ -n "$SSH_CONNECTION" ]; then
      FILE_VALUE=$(cat "$HOME/development/environment/project/.config/ssh-notice" || true)
      if [ -z "$FILE_VALUE" ]; then
        SSH_NOTICE=" [SSH]"
      else
        SSH_NOTICE=" [$(echo "$FILE_VALUE" | tr -d '\n')]"
      fi
    elif [ -f ~/.check_files/init_docker ]; then
      SSH_NOTICE=" [DOCKER_ENV]"
    fi

    if [ "$IS_BASH" -eq 1 ]; then
      COLOR=$(translate_color_to_ansi "$SSH_NOTICE_COLOR")
      CURRENT_DIRECTORY=$(basename "$PWD")
      echo "$COLOR""$SSH_NOTICE $ANSI_COLOR_GREEN""$CURRENT_DIRECTORY"
    else
      echo "%F{$SSH_NOTICE_COLOR}$SSH_NOTICE %F{green}%1d"
    fi
  }

  get_vpn() {
    if [ "$(cat ~/development/environment/project/".config/vpn_check" 2>/dev/null || true)" != "yes" ]; then
      return
    fi

    VPN_RUNNING=$(ps aux | grep -v grep | grep -q openvpn && echo yes || echo no)

    if [ "$VPN_RUNNING" = "no" ]; then
      echo " %F{red}NO_VPN%F{reset_color}"
    fi
  }

  get_tailscale_status() {
    if ! type tailscale >/dev/null 2>&1; then
      return
    fi

    if [ -f "$HOME/development/environment/project/.config/ps1-no-tailscale" ]; then
      return
    fi

    TAILSCALE_STATUS=$(tailscale status --peers=false 2>&1 | grep -vqE '(stopped|Logged out|client version)' && echo connected || echo '')

    if [ -z "$TAILSCALE_STATUS" ]; then
      return
    fi

    echo " %F{yellow}[TS]%F{reset_color}"
  }

  get_git_ps1() {
    RESULT=$(bash -c ". ~/.git-prompt && __git_ps1" || true)

    if [ "$IS_BASH" -eq 1 ]; then
      echo "$ANSI_COLOR_GREEN""$RESULT""$ANSI_COLOR_RESET"
    else
      echo "%F{green}$RESULT%F{reset_color}"
    fi
  }

  JOBS_ARGS="$1"
  get_background_jobs() {
    if [ "$IS_BASH" -eq 1 ]; then
      JOBS="$(echo "$JOBS_ARGS" | grep . | wc -l || true)"
    else
      # The format is Xr/Ys where X is the running number and Y is the suspended number
      RUNNING_JOBS="$(echo $JOBS_ARGS | sed 's|/.*$||' | sed 's|r||')"
      SUSPENDED_JOBS="$(echo $JOBS_ARGS | sed 's|^[^/]*/||' | sed 's|s||')"
      JOBS=$((RUNNING_JOBS + SUSPENDED_JOBS))
    fi

    if [ -z "$JOBS" ] || [ "$JOBS" -eq 0 ]; then
      return
    fi

    echo " $JOBS"
  }

  TMUX_WINDOW_INDEX="$(get_tmux_window_index)"
  if [ -n "$TMUX_WINDOW_INDEX" ]; then
    TMUX_PREFIX_A="$TMUX_WINDOW_INDEX"
    TMUX_PREFIX_B=""
  else
    TMUX_PREFIX_A=""
    TMUX_PREFIX_B=" ·"
  fi

  SSH_NOTICE="$(get_ssh_notice)"
  VPN_RESULT="$(get_vpn)"
  TAILSCALE="$(get_tailscale_status)"
  GIT_PS1="$(get_git_ps1)"
  JOBS_PREFIX="$(get_background_jobs)"

  PS1_START="$TMUX_PREFIX_A""$NIX_PREFIX""$SSH_NOTICE""$VPN_RESULT""$TAILSCALE"
  PS1_MIDDLE="$GIT_PS1""$JOBS_PREFIX"
  TIME=$(date +%H:%M)

  if [ "$IS_BASH" -eq 1 ]; then
    PS1_END="$ANSI_COLOR_BLUE""$TIME""$TMUX_PREFIX_B""$ANSI_COLOR_RESET"
    printf "\n\n$PS1_START""$PS1_MIDDLE $PS1_END "
  else
    PS1_END="%F{39}$TIME""$TMUX_PREFIX_B%F{reset_color}"
    echo "\n\n$PS1_START""$PS1_MIDDLE $PS1_END "
  fi
}

provision_get_ps1_right() {
  printf ""
}
