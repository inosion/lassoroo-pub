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
| `GITHUB_TOKEN` or `GH_TOKEN` | Token for downloading while this repository is private | none |

### While this repository is private

Anonymous downloads (including `raw.githubusercontent.com`) return 404 until the repository
is public. Use a token with read access to it, for example with the GitHub CLI:

```sh
export GH_TOKEN="$(gh auth token)"
curl -fsSL -H "Authorization: Bearer $GH_TOKEN" \
  https://raw.githubusercontent.com/inosion/lassoroo-pub/main/install.sh | bash
```

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
