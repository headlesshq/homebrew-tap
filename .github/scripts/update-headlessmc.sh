#!/usr/bin/env bash
# Renders Formula/headlessmc.rb for a HeadlessMc release.
# Usage: update-headlessmc.sh [tag]   (defaults to the latest release)
# Requires: gh (authenticated via GH_TOKEN), awk, curl, shasum or sha256sum.
set -euo pipefail

REPO="headlesshq/headlessmc"
FORMULA="$(cd "$(dirname "$0")/../.." && pwd)/Formula/headlessmc.rb"
TAG="${1:-}"
if [[ -z "$TAG" ]]; then
  TAG="$(gh release view --repo "$REPO" --json tagName --jq .tagName)"
fi
VERSION="${TAG#v}"
BASE="https://github.com/$REPO/releases/download/$TAG"

sha256() {
  if command -v sha256sum >/dev/null; then sha256sum | cut -d' ' -f1; else shasum -a 256 | cut -d' ' -f1; fi
}

# "name sha256:..." per asset; GitHub computes these on upload, so we don't
# have to download ~90 MB per binary (which also hit transient 504s)
DIGESTS="$(gh api "repos/$REPO/releases/tags/$TAG" --jq '.assets[] | "\(.name) \(.digest // "")"')"

hash_target() {
  local name="headlessmc-launcher-$1" digest
  digest="$(awk -v n="$name" '$1 == n { sub(/^sha256:/, "", $2); print $2 }' <<<"$DIGESTS")"
  if [[ "$digest" =~ ^[0-9a-f]{64}$ ]]; then
    echo "Using GitHub digest for $name ($TAG)" >&2
    echo "$digest"
    return
  fi
  echo "Hashing $name ($TAG)" >&2
  curl -fsSL --retry 5 --retry-delay 10 --retry-all-errors "$BASE/$name" | sha256
}

# plain variables instead of an associative array, so this also runs on the bash 3 of macOS
SHA_MACOS_ARM64="$(hash_target macos-arm64)"
SHA_MACOS_X64="$(hash_target macos-x64)"
SHA_LINUX_ARM64="$(hash_target linux-arm64)"
SHA_LINUX_X64="$(hash_target linux-x64)"

cat > "$FORMULA" <<RUBY
class Headlessmc < Formula
  desc "Command-line launcher for Minecraft Java Edition"
  homepage "https://headlesshq.github.io/headlessmc/"
  version "$VERSION"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest do |json, _regex|
      json["tag_name"]&.delete_prefix("v")
    end
  end

  on_macos do
    on_arm do
      url "$BASE/headlessmc-launcher-macos-arm64"
      sha256 "$SHA_MACOS_ARM64"
    end
    on_intel do
      url "$BASE/headlessmc-launcher-macos-x64"
      sha256 "$SHA_MACOS_X64"
    end
  end

  on_linux do
    on_arm do
      url "$BASE/headlessmc-launcher-linux-arm64"
      sha256 "$SHA_LINUX_ARM64"
    end
    on_intel do
      url "$BASE/headlessmc-launcher-linux-x64"
      sha256 "$SHA_LINUX_X64"
    end
  end

  def install
    # each url downloads a single native executable
    bin.install Dir["headlessmc-launcher-*"].first => "headlessmc"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/headlessmc --version")
  end
end
RUBY

echo "Updated $FORMULA to $VERSION" >&2
