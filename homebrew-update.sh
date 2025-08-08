#!/usr/bin/env bash

# homebrew-update.sh
# Script to install or update common applications using Homebrew.
# This script checks whether Homebrew is installed, installs it if needed,
# and then ensures that a predefined list of applications are installed
# and up to date. Customize the APPS array to fit your needs.

set -euo pipefail

# Command-line tools to install/upgrade
APPS=(git wget node python3 htop tmux)

# GUI applications distributed as casks
CASKS=(
  1password
  google-chrome
  brave-browser
  slack
  zoom
  raycast
  cursor 
  chatgpt
  claude
  )

install_homebrew() {
  echo "Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

ensure_app_installed() {
  local app="$1"
  if brew list "$app" >/dev/null 2>&1; then
    echo "Upgrading $app..."
    brew upgrade "$app" || true
  else
    echo "Installing $app..."
    brew install "$app"
  fi
}

ensure_cask_installed() {
  local app="$1"
  if brew list --cask "$app" >/dev/null 2>&1; then
    echo "Upgrading $app..."
    brew upgrade --cask "$app" || true
  else
    echo "Installing $app..."
    brew install --cask "$app"
  fi
}

main() {
  if ! command -v brew >/dev/null 2>&1; then
    install_homebrew
  fi

  echo "Updating Homebrew..."
  brew update

  for app in "${APPS[@]}"; do
    ensure_app_installed "$app"
  done

  # Build a list of casks that are not yet installed
  local -a CASKS_TO_INSTALL=()
  for cask in "${CASKS[@]}"; do
    if ! brew list --cask "$cask" >/dev/null 2>&1; then
      CASKS_TO_INSTALL+=("$cask")
    fi
  done

  if ((${#CASKS_TO_INSTALL[@]} > 0)); then
    echo "Casks to install:"
    printf '  - %s\n' "${CASKS_TO_INSTALL[@]}"
  else
    echo "No new casks to install."
  fi

  for cask in "${CASKS[@]}"; do
    ensure_cask_installed "$cask"
  done

  echo "Cleaning up..."
  # Measure cache size before cleanup
  local cache_dir
  cache_dir="$(brew --cache)"
  local before_cache_size="0B"
  if [[ -d "$cache_dir" ]]; then
    before_cache_size="$(du -sh "$cache_dir" 2>/dev/null | awk '{print $1}')"
  fi

  echo "Removing unused dependencies..."
  brew autoremove || true

  echo "Pruning old versions and scrubbing caches..."
  brew cleanup -s --prune=all || true

  # Measure cache size after cleanup
  local after_cache_size="0B"
  if [[ -d "$cache_dir" ]]; then
    after_cache_size="$(du -sh "$cache_dir" 2>/dev/null | awk '{print $1}')"
  fi
  echo "Homebrew cache size: ${before_cache_size} -> ${after_cache_size}"

  echo "All apps are up to date!"
}

main "$@"
