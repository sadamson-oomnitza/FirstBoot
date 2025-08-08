# FirstBoot

Script to set core apps and settings for new deployment.

## Homebrew app updater

Use `./homebrew-update.sh` to ensure that common applications are installed on a new macOS machine. The script installs Homebrew if needed and then installs any missing tools in the `APPS` array and macOS applications in the `CASKS` array (skips items already installed).

### What the script does

- **Installs Homebrew if missing**: Automatically installs Homebrew when not found.
- **Updates Homebrew**: Runs `brew update`.
- **Ensures CLI tools are present**: Installs items in `APPS` if missing; skips if already installed.
- **Validates cask tokens**: Warns and skips unknown/invalid casks.
- **Shows missing casks before installing**: Prints a bullet list of macOS apps in `CASKS` that are not yet installed, e.g.:

  ```
  Casks to install:
    - 1password
    - google-chrome
    - brave-browser
    - slack
    - zoom
    - raycast
    - cursor
    - chatgpt
    - claude
  ```

- **Installs casks if missing**: Skips casks already installed. If an app bundle exists in `/Applications` but isn’t under Homebrew, the script attempts to adopt it using a forced install.
- **Thorough cleanup**:
  - Runs `brew autoremove` to remove unused dependencies
  - Runs `brew cleanup -s --prune=all` to prune old versions and scrub caches
  - Reports Homebrew cache size before and after cleanup

```bash
./homebrew-update.sh
```

### Setup

```bash
chmod +x homebrew-update.sh
./homebrew-update.sh
```

You can also run it directly with Bash: `bash homebrew-update.sh`.

### Customize the app lists

Edit `homebrew-update.sh` and adjust the arrays near the top of the file:

- **`APPS`**: Command-line tools (installed via `brew install`).
- **`CASKS`**: macOS GUI apps (installed via `brew install --cask`).

The `CASKS` list is formatted on multiple lines for readability, for example:

```bash
CASKS=(
  1password
  1password-cli
  appcleaner
  brave-browser
  bruno
  chatgpt
  claude
  cleanshot
  cursor
  google-chrome
  imazing-profile-editor
  itsycal
  raycast
  slack
  zoom
)
```

### Notes

- The script is idempotent and safe to re-run; items already installed are skipped (no upgrades performed by default).
- Cleanup is aggressive by default and will attempt to remove old downloads and cached files; the script prints cache size before and after so you can see the effect.
- After installing Homebrew, the script ensures `brew` is available in the current shell session.
