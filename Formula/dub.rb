class Dub < Formula
  desc "Build tool for D projects"
  homepage "https://code.dlang.org/getting_started"
  url "https://github.com/dlang/dub/archive/v1.18.0.tar.gz"
  sha256 "5ea118388217ad9afe7ccd6a486c0139c39a45e464de662fecfa142a408c1880"
  version_scheme 1
  head "https://github.com/dlang/dub.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "bf9fce6bc8be76547f3fb0aa6fd0ac96762d13ffc6db365b1c571eaa4edaa8fe" => :mojave
    sha256 "91b64a2a139ea068832c053a97798e5adb79736a052a89732dcc950789e700f9" => :high_sierra
    sha256 "434b0862c37564e3ac7764dd92a75f7f092b373ba0792c9a628974946417a5df" => :sierra
    sha256 "412baa4c61a3eb3e0a1545fcbf5b4d94e40424a3997b779f82f36441503abfe3" => :x86_64_linux
  end

  depends_on "dmd" => :build
  depends_on "pkg-config"
  uses_from_macos "curl"

  def install
    ENV["GITVER"] = version.to_s
    system "./build.sh"
    bin.install "bin/dub"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/dub --version").split(/[ ,]/)[2]
  end
end
