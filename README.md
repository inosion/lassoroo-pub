# Lassoroo

Lasso land, snip trails, steal territory. Real players, one thumb.

This repository holds **releases only**. It contains no source code.

## Install (Linux and macOS)

```sh
curl -fsSL https://raw.githubusercontent.com/inosion/lassoroo-pub/main/install.sh | bash
```

This downloads the newest release for your machine, checks it against the published
`SHA256SUMS`, and installs `lassoroo` into `~/.local/bin`. Run it again to update.

| Platform | Supported |
| --- | --- |
| Linux x86_64 | ✅ |
| macOS, Apple silicon | ✅ |
| macOS, Intel | not yet |
| Windows x86_64 | download the `.zip` from Releases |

### Options

Set these before `bash`, e.g. `curl -fsSL … | LASSOROO_VERSION=v0.1.0 bash`:

| Variable | Meaning | Default |
| --- | --- | --- |
| `LASSOROO_VERSION` | Release tag to install | newest release |
| `LASSOROO_INSTALL_DIR` | Where to put the `lassoroo` binary | `~/.local/bin` |
| `GITHUB_TOKEN` or `GH_TOKEN` | GitHub token, to avoid anonymous rate limits | none |

### Rate limits

Without a token, GitHub allows 60 API requests an hour per IP address, and an install uses
about 3. If many people install from one network at once, set a token first:
`export GH_TOKEN="$(gh auth token)"`.

## Manual download

Every [release](../../releases) has a `.tar.gz` (Linux, macOS) or `.zip` (Windows) per
platform, and a `SHA256SUMS` file to verify them.

macOS builds are not yet notarised. If macOS refuses to open a manually downloaded copy, run
`xattr -d com.apple.quarantine lassoroo` once (the install script does this for you).

## Uninstall

```sh
rm ~/.local/bin/lassoroo
rm -rf ~/.local/share/lassoroo                  # Linux: saved identity
rm -rf ~/Library/Application\ Support/lassoroo  # macOS: saved identity
```
