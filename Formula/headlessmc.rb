class Headlessmc < Formula
  desc "Command-line launcher for Minecraft Java Edition"
  homepage "https://headlesshq.github.io/headlessmc/"
  version "3.0.0-RC8"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest do |json, _regex|
      json["tag_name"]&.delete_prefix("v")
    end
  end

  on_macos do
    on_arm do
      url "https://github.com/headlesshq/headlessmc/releases/download/3.0.0-RC8/headlessmc-launcher-macos-arm64"
      sha256 "fc9d636a715a206e11480869c2ef7e97a9ba919e84d56b376aa301360d105060"
    end
    on_intel do
      url "https://github.com/headlesshq/headlessmc/releases/download/3.0.0-RC8/headlessmc-launcher-macos-x64"
      sha256 "d37e9d206b0245f13f9855c16c3ebb1554542fa694b10bcaacf2afe5b928fb67"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/headlesshq/headlessmc/releases/download/3.0.0-RC8/headlessmc-launcher-linux-arm64"
      sha256 "0d5298df7f344b529cb63c1203e8e25ccb0f3bb58d6795e38ad8f3cf6c331dec"
    end
    on_intel do
      url "https://github.com/headlesshq/headlessmc/releases/download/3.0.0-RC8/headlessmc-launcher-linux-x64"
      sha256 "62bbcd85344470bc1c11e08be4eda33ce06aeff2ed2931c87964640d5a733ece"
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
