#!/usr/bin/env bash

# homebrew-update.sh
# Script to install or update common applications using Homebrew.
# This script checks whether Homebrew is installed, installs it if needed,
# and then ensures that a predefined list of applications are installed
# and up to date. Customize the APPS array to fit your needs.

set -euo pipefail

# Command-line tools to install/upgrade
APPS=(
  git
  wget
  node
  python3
  htop
  tmux
  )

# GUI applications distributed as casks
CASKS=(
  1password
  1password-cli
  brave-browser
  bruno
  chatgpt
  cursor
  google-chrome
  raycast
  slack
  zoom
  imazing-profile-editor
  appcleaner
  claude
  itsycal
  cleanshot
)

install_homebrew() {
  echo "Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

ensure_brew_in_path() {
  # Ensure the current shell can find brew after installation
  if command -v brew >/dev/null 2>&1; then
    return
  fi
  if [[ -x "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

print_list() {
  local title="$1"; shift || true
  local -a items=("$@")
  if ((${#items[@]} > 0)); then
    echo "$title"
    printf '  - %s\n' "${items[@]}"
  fi
}

set_macos_preferences() {
  echo "Configuring macOS preferences (tap to click)..."

  # Enable tap to click for the current user (covering internal and Bluetooth trackpads)
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true || true
  defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true || true
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1 || true
  defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1 || true

  # Enable tap to click at the login screen (system-wide). Requires sudo.
  if command -v sudo >/dev/null 2>&1; then
    sudo -n true 2>/dev/null || true
    sudo defaults write /Library/Preferences/com.apple.AppleMultitouchTrackpad Clicking -bool true || true
    sudo defaults write /Library/Preferences/com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true || true
    sudo defaults -currentHost write /Library/Preferences/.GlobalPreferences com.apple.mouse.tapBehavior -int 1 || true
    sudo defaults write /Library/Preferences/.GlobalPreferences com.apple.mouse.tapBehavior -int 1 || true
  fi

  # Apply changes
  killall SystemUIServer >/dev/null 2>&1 || true
}

set_dock_preferences() {
  echo "Configuring Dock (left position; removing News)..."

  # Position Dock on the left side
  defaults write com.apple.dock orientation -string left || true

  # Remove News.app from the Dock persistent apps
  local dock_plist
  dock_plist="$HOME/Library/Preferences/com.apple.dock.plist"
  if [[ -f "$dock_plist" ]]; then
    local -a indices_to_delete=()
    local i=0
    while /usr/libexec/PlistBuddy -c "Print :persistent-apps:$i" "$dock_plist" >/dev/null 2>&1; do
      local label url
      label=$(/usr/libexec/PlistBuddy -c "Print :persistent-apps:$i:tile-data:file-label" "$dock_plist" 2>/dev/null || echo "")
      url=$(/usr/libexec/PlistBuddy -c "Print :persistent-apps:$i:tile-data:file-data:_CFURLString" "$dock_plist" 2>/dev/null || echo "")
      if [[ "$label" == "News" ]] || [[ "$url" == *"/News.app"* ]]; then
        indices_to_delete+=("$i")
      fi
      ((i++))
    done
    if ((${#indices_to_delete[@]} > 0)); then
      for idx in $(printf "%s\n" "${indices_to_delete[@]}" | sort -nr); do
        /usr/libexec/PlistBuddy -c "Delete :persistent-apps:$idx" "$dock_plist" >/dev/null 2>&1 || true
      done
    fi
  fi

  # Restart Dock to apply changes
  killall Dock >/dev/null 2>&1 || true
}

set_night_shift_sunset_to_sunrise() {
  echo "Configuring Night Shift schedule (sunset to sunrise)..."

  # Prefer editing the ByHost CoreBrightness plist directly for reliability
  local byhost_plist
  byhost_plist=$(ls "$HOME/Library/Preferences/ByHost/com.apple.CoreBrightness."*.plist 2>/dev/null | head -n1 || true)
  if [[ -n "$byhost_plist" && -f "$byhost_plist" ]]; then
    local user_key
    user_key=$(/usr/libexec/PlistBuddy -c "Print" "$byhost_plist" 2>/dev/null | awk -F' =' '/CBUser-/{print $1; exit}' || true)
    if [[ -n "$user_key" ]]; then
      /usr/libexec/PlistBuddy -c "Add :$user_key:CBBlueLightReductionStatus integer 1" "$byhost_plist" 2>/dev/null || \
      /usr/libexec/PlistBuddy -c "Set :$user_key:CBBlueLightReductionStatus 1" "$byhost_plist" 2>/dev/null || true

      /usr/libexec/PlistBuddy -c "Add :$user_key:CBBlueLightReductionSchedule dict" "$byhost_plist" 2>/dev/null || true

      /usr/libexec/PlistBuddy -c "Add :$user_key:CBBlueLightReductionSchedule:enabled bool true" "$byhost_plist" 2>/dev/null || \
      /usr/libexec/PlistBuddy -c "Set :$user_key:CBBlueLightReductionSchedule:enabled true" "$byhost_plist" 2>/dev/null || true

      /usr/libexec/PlistBuddy -c "Add :$user_key:CBBlueLightReductionSchedule:sunsetToSunrise bool true" "$byhost_plist" 2>/dev/null || \
      /usr/libexec/PlistBuddy -c "Set :$user_key:CBBlueLightReductionSchedule:sunsetToSunrise true" "$byhost_plist" 2>/dev/null || true

      # Alternate key casing observed on some versions
      /usr/libexec/PlistBuddy -c "Add :$user_key:CBBlueLightReductionSchedule:SunsetToSunrise bool true" "$byhost_plist" 2>/dev/null || \
      /usr/libexec/PlistBuddy -c "Set :$user_key:CBBlueLightReductionSchedule:SunsetToSunrise true" "$byhost_plist" 2>/dev/null || true

      killall cfprefsd >/dev/null 2>&1 || true
      return
    fi
  fi

  # Fallback using defaults, may be less reliable across versions
  defaults -currentHost write com.apple.CoreBrightness CBBlueLightReductionStatus -int 1 || true
  defaults -currentHost write com.apple.CoreBrightness CBBlueLightReductionSchedule -dict-add enabled -bool true 2>/dev/null || true
  defaults -currentHost write com.apple.CoreBrightness CBBlueLightReductionSchedule -dict-add sunsetToSunrise -bool true 2>/dev/null || true
  defaults -currentHost write com.apple.CoreBrightness CBBlueLightReductionSchedule -dict-add SunsetToSunrise -bool true 2>/dev/null || true
  killall cfprefsd >/dev/null 2>&1 || true
}

ensure_app_installed() {
  local app="$1"
  if brew list "$app" >/dev/null 2>&1; then
    echo "Already installed: $app"
  else
    echo "Installing $app..."
    brew install "$app"
  fi
}

ensure_cask_installed() {
  local app="$1"
  if brew list --cask "$app" >/dev/null 2>&1; then
    echo "Already installed: $app"
  else
    echo "Installing $app..."
    local install_output
    if ! install_output=$(brew install --cask "$app" 2>&1); then
      if [[ "$install_output" == *"already an App at"* ]] || \
         [[ "$install_output" == *"already exists at"* ]] || \
         [[ "$install_output" == *"already exists"* ]]; then
        echo "Detected existing app bundle for $app. Attempting to adopt under Homebrew (forced install)..."
        brew install --cask --force "$app" || brew reinstall --cask --force "$app" || true
      else
        echo "$install_output"
        return 1
      fi
    fi
  fi
}

main() {
  if ! command -v brew >/dev/null 2>&1; then
    install_homebrew
  fi
  ensure_brew_in_path

  echo "Updating Homebrew..."
  brew update

  # Determine which formulae are missing
  local -a APPS_TO_INSTALL=()
  for app in "${APPS[@]}"; do
    if ! brew list "$app" >/dev/null 2>&1; then
      APPS_TO_INSTALL+=("$app")
    fi
  done

  if ((${#APPS_TO_INSTALL[@]} > 0)); then
    print_list "Formulae to install:" "${APPS_TO_INSTALL[@]}"
  else
    echo "No new formulae to install."
  fi

  for app in "${APPS[@]}"; do
    ensure_app_installed "$app"
  done

  # Validate cask tokens and build a list of valid casks
  local -a VALID_CASKS=()
  local -a UNKNOWN_CASKS=()
  for cask in "${CASKS[@]}"; do
    if brew info --cask "$cask" >/dev/null 2>&1; then
      VALID_CASKS+=("$cask")
    else
      UNKNOWN_CASKS+=("$cask")
    fi
  done

  if ((${#UNKNOWN_CASKS[@]} > 0)); then
    print_list "Warning: Unknown casks (skipping):" "${UNKNOWN_CASKS[@]}"
  fi

  # Build a list of casks that are not yet installed
  local -a CASKS_TO_INSTALL=()
  for cask in "${VALID_CASKS[@]}"; do
    if ! brew list --cask "$cask" >/dev/null 2>&1; then
      CASKS_TO_INSTALL+=("$cask")
    fi
  done

  if ((${#CASKS_TO_INSTALL[@]} > 0)); then
    print_list "Casks to install:" "${CASKS_TO_INSTALL[@]}"
  else
    echo "No new casks to install."
  fi

  for cask in "${VALID_CASKS[@]}"; do
    ensure_cask_installed "$cask"
  done

  # Configure core macOS preferences
  set_macos_preferences
  set_night_shift_sunset_to_sunrise
  set_dock_preferences
  configure_night_shift

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

  echo "Setup complete."
}

main "$@"
