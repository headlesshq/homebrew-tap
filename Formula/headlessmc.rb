class Headlessmc < Formula
  desc "Command-line launcher for Minecraft Java Edition"
  homepage "https://headlesshq.github.io/headlessmc/"
  version "3.0.0-RC9"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest do |json, _regex|
      json["tag_name"]&.delete_prefix("v")
    end
  end

  on_macos do
    on_arm do
      url "https://github.com/headlesshq/headlessmc/releases/download/3.0.0-RC9/headlessmc-launcher-macos-arm64"
      sha256 "419cc239a4313b7f8751206f1046e266f61e6b1bfb8bd195e972e710dd5ff377"
    end
    on_intel do
      url "https://github.com/headlesshq/headlessmc/releases/download/3.0.0-RC9/headlessmc-launcher-macos-x64"
      sha256 "43303c41536997d0d718c81028b2c2220bc39a15e2d3de27e12d6d9c3eb3b323"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/headlesshq/headlessmc/releases/download/3.0.0-RC9/headlessmc-launcher-linux-arm64"
      sha256 "7e83c6555a072820592f312476a45a35369391df0e63092fc6b5a41f8d06fecf"
    end
    on_intel do
      url "https://github.com/headlesshq/headlessmc/releases/download/3.0.0-RC9/headlessmc-launcher-linux-x64"
      sha256 "1f262b3e2f35569e437635bb958ab766da70e4619530b46f23cbc69dea85c318"
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
