class Dub < Formula
  desc "Build tool for D projects"
  homepage "https://code.dlang.org/about"
  url "https://github.com/D-Programming-Language/dub/archive/v0.9.24.tar.gz"
  sha256 "88fe9ff507d47cb74af685ad234158426219b7fdd7609de016fc6f5199def866"
  head "https://github.com/D-Programming-Language/dub.git", :shallow => false

  bottle do
    sha256 "bf14b900869d28bc8140731ee81d04d9ee5b456603dea51353863bd76358f49d" => :el_capitan
    sha256 "5cdd5f8c6729f3acf955afbd8d383daf196318bf1d2278085a28c28af00d33ce" => :yosemite
    sha256 "33db147c048a39cad51569940ff489e015a08f3d17d0c299efcce89c064a8513" => :mavericks
    sha256 "52c85c092e9cb32a0964f3917842397f98015084d8d7404eef62fc00047d527c" => :x86_64_linux
  end

  devel do
    url "https://github.com/rejectedsoftware/dub/archive/v0.9.25-beta.3.tar.gz"
    sha256 "c67dc40757cbe0b422f7d38669b786ff344a7dc752bb78aa1652c2b0c405de34"
    version "0.9.25-beta.3"
  end

  depends_on "pkg-config" => :build
  depends_on "dmd" => :build
  depends_on "curl" unless OS.mac?

  def install
    # fix https://github.com/Linuxbrew/homebrew-core/issues/439
    system "export DMD=${HOMEBREW_PREFIX}/bin/dmd && ./build.sh"
    bin.install "bin/dub"
  end

  test do
    system "#{bin}/dub; true"
  end
end
