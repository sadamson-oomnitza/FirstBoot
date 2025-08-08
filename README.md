# FirstBoot

Script to set core apps and settings for new deployment.

## Homebrew app updater

Use `./homebrew-update.sh` to ensure that common applications are installed and up to date on a new macOS machine. The script will install Homebrew if it isn't present and then install or upgrade the tools listed in the `APPS` array and the macOS applications listed in the `CASKS` array.

### What the script does

- **Installs Homebrew if missing**: Automatically installs Homebrew when not found.
- **Updates Homebrew**: Runs `brew update`.
- **Ensures CLI tools are present**: Iterates the `APPS` array, installing or upgrading each.
- **Shows missing casks before installing**: Prints a readable, bullet list of macOS apps in `CASKS` that are not yet installed, e.g.:

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

- **Installs/upgrades casks**: Ensures each cask in `CASKS` is installed or upgraded.
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
  google-chrome
  brave-browser
  slack
  zoom
  raycast
  cursor
  chatgpt
  claude
)
```

### Notes

- The script is idempotent and safe to re-run; already installed apps will be upgraded when updates are available.
- Cleanup is aggressive by default and will attempt to remove old downloads and cached files; the script prints cache size before and after so you can see the effect.
