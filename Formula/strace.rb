# strace: Build a bottle for Linuxbrew
class Strace < Formula
  desc "A useful diagnostic, instructional, and debugging tool"
  homepage "http://sourceforge.net/projects/strace/"
  url "https://downloads.sourceforge.net/project/strace/strace/4.10/strace-4.10.tar.xz"
  sha256 "e6180d866ef9e76586b96e2ece2bfeeb3aa23f5cc88153f76e9caedd65e40ee2"
  head "git://strace.git.sourceforge.net/gitroot/strace/strace"
  # tag "linuxbrew"

  bottle do
    cellar :any_skip_relocation
    sha256 "038d8d843299fe9d92b858e5349354004d71c3aa14e4e1c91c076445ccbd3669" => :x86_64_linux
  end

  depends_on "linux-headers"

  def install
    system "./configure",
      "--disable-debug",
      "--disable-dependency-tracking",
      "--disable-silent-rules",
      "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    out = `"strace" "true" 2>&1` # strace the true command, redirect stderr to output
    assert_match "execve(", out
    assert_match "+++ exited with 0 +++", out
  end
end
