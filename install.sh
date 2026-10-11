#!/usr/bin/env bash
# Installs the Lassoroo desktop game on Linux or macOS.
#
#   curl -fsSL https://raw.githubusercontent.com/inosion/lassoroo-pub/main/install.sh | bash
#
# Options (environment variables):
#   LASSOROO_VERSION       release tag to install (default: the newest release)
#   LASSOROO_INSTALL_DIR   where to put the binary (default: ~/.local/bin)
#   GITHUB_TOKEN/GH_TOKEN  GitHub token (avoids anonymous API rate limits; needed if private)
#
# This file is published to the releases repository by the release workflow; edit it in
# the source repository (publish/install.sh).

# Everything is inside main() so a partially downloaded script never runs.
main() {
    set -euo pipefail

    local repo="${LASSOROO_REPO:-inosion/lassoroo-pub}"
    local api="${LASSOROO_API:-https://api.github.com}"
    local product="lassoroo"
    local install_dir="${LASSOROO_INSTALL_DIR:-$HOME/.local/bin}"
    local token="${GITHUB_TOKEN:-${GH_TOKEN:-}}"

    say() { printf '\033[1m%s\033[0m\n' "$*" >&2; }
    die() { printf '\033[31merror:\033[0m %s\n' "$*" >&2; exit 1; }
    need() { command -v "$1" > /dev/null 2>&1 || die "this installer needs '$1'"; }
    need curl
    need tar
    need uname

    # Which build fits this machine.
    local os arch target
    os="$(uname -s)"
    arch="$(uname -m)"
    case "$os/$arch" in
        Linux/x86_64 | Linux/amd64) target="x86_64-unknown-linux-gnu" ;;
        Darwin/arm64 | Darwin/aarch64) target="aarch64-apple-darwin" ;;
        Darwin/x86_64)
            # Under Rosetta, uname reports x86_64 on Apple silicon.
            if [ "$(sysctl -n sysctl.proc_translated 2> /dev/null || echo 0)" = "1" ]; then
                target="aarch64-apple-darwin"
            else
                die "Intel Macs are not supported yet (Apple silicon only)"
            fi
            ;;
        *) die "no build for $os $arch yet (supported: Linux x86_64, macOS Apple silicon)" ;;
    esac

    local auth=()
    if [ -n "$token" ]; then
        auth=(-H "Authorization: Bearer $token")
    fi
    fetch() { curl -fsSL --retry 3 ${auth[@]+"${auth[@]}"} "$@"; }

    # One JSON field per line, whether the API pretty-printed its response or not.
    json_lines() { printf '%s' "$release_json" | tr ',{}[]' '\n\n\n\n\n'; }

    # The release to install: as requested, otherwise the newest (pre-releases included).
    local release_json tag
    if [ -n "${LASSOROO_VERSION:-}" ]; then
        tag="$LASSOROO_VERSION"
        release_json="$(fetch "$api/repos/$repo/releases/tags/$tag")" ||
            die "release $tag not found (network problem or GitHub rate limit? try again, or set GH_TOKEN)"
    else
        release_json="$(fetch "$api/repos/$repo/releases?per_page=1")" ||
            die "could not list releases (network problem or GitHub rate limit? try again, or set GH_TOKEN)"
        tag="$(json_lines | grep -m1 '"tag_name"' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/')"
        [ -n "$tag" ] || die "no releases published yet"
    fi

    local archive="$product-$tag-$target.tar.gz"
    say "Installing $product $tag for $target"

    # Asset API URLs (work for private repositories with a token) keyed by file name.
    asset_url() {
        json_lines | awk -v want="$1" '
            /"url": *".*\/releases\/assets\/[0-9]+"/ { match($0, /http[s]?:[^"]+/); url = substr($0, RSTART, RLENGTH) }
            /"name": *"/ { match($0, /"name": *"[^"]+"/); n = substr($0, RSTART, RLENGTH); sub(/"name": *"/, "", n); sub(/"$/, "", n); if (n == want) { print url; exit } }'
    }
    download() { # <asset name> <output file>
        local url
        url="$(asset_url "$1")"
        [ -n "$url" ] || die "this release has no $1"
        fetch -H "Accept: application/octet-stream" -o "$2" "$url"
    }

    local tmp
    tmp="$(mktemp -d)"
    # shellcheck disable=SC2064 # expand now: $tmp is local to main
    trap "rm -rf '$tmp'" EXIT
    download "$archive" "$tmp/$archive"
    download SHA256SUMS "$tmp/SHA256SUMS"

    # Verify the download.
    local expected actual
    expected="$(grep " $archive\$" "$tmp/SHA256SUMS" | cut -d' ' -f1)"
    [ -n "$expected" ] || die "no checksum for $archive"
    if command -v sha256sum > /dev/null 2>&1; then
        actual="$(sha256sum "$tmp/$archive" | cut -d' ' -f1)"
    else
        actual="$(shasum -a 256 "$tmp/$archive" | cut -d' ' -f1)"
    fi
    [ "$expected" = "$actual" ] || die "checksum mismatch for $archive"

    tar -xzf "$tmp/$archive" -C "$tmp"
    mkdir -p "$install_dir"
    install -m 0755 "$tmp/$product-$tag-$target/$product" "$install_dir/$product"
    if [ "$os" = "Darwin" ]; then
        xattr -d com.apple.quarantine "$install_dir/$product" 2> /dev/null || true
    fi

    say "Installed $install_dir/$product"
    case ":$PATH:" in
        *":$install_dir:"*) say "Run: $product" ;;
        *) say "Add $install_dir to your PATH, then run: $product" ;;
    esac
}

main "$@"
