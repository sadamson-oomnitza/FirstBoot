# FirstBoot

Script to set core apps and settings for new deployment.

## Homebrew app updater

Use `./homebrew-update.sh` to ensure that common applications are installed and up to date on a new macOS machine. The script will install Homebrew if it isn't present and then install or upgrade the apps listed in the `APPS` array inside the script.

```bash
./homebrew-update.sh
```

Customize the `APPS` variable in the script to match the tools you want on your system.
