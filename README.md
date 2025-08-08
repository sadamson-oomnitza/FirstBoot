# FirstBoot

Script to set core apps and settings for new deployment.

## Homebrew app updater

Use `./homebrew-update.sh` to ensure that common applications are installed and up to date on a new macOS machine. The script will install Homebrew if it isn't present and then install or upgrade the tools listed in the `APPS` array and the macOS applications listed in the `CASKS` array.

```bash
./homebrew-update.sh
```

Customize the `APPS` and `CASKS` variables in the script to match the tools and apps you want on your system.
