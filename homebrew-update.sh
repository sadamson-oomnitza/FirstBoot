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
CASKS=(1password cursor chatgpt)

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

  for cask in "${CASKS[@]}"; do
    ensure_cask_installed "$cask"
  done

  echo "Cleaning up..."
  brew cleanup
  echo "All apps are up to date!"
}

main "$@"
