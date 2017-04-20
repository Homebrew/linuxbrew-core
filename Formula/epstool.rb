# epstool: Build a bottle for Linuxbrew
class Epstool < Formula
  desc "Edit preview images and fix bounding boxes in EPS files"
  homepage "http://pages.cs.wisc.edu/~ghost/gsview/epstool.htm"
  url "http://pkgs.fedoraproject.org/repo/pkgs/epstool/epstool-3.08.tar.gz/465a57a598dbef411f4ecbfbd7d4c8d7/epstool-3.08.tar.gz"
  mirror "https://dl.bintray.com/homebrew/mirror/epstool-3.08.tar.gz"
  sha256 "f3f14b95146868ff3f93c8720d5539deef3b6531630a552165664c7ee3c2cfdd"

  bottle do
    cellar :any_skip_relocation
    sha256 "d53d1f3d353d0f68f52b87603a67ca97942fb714f766a54636c142550568cbd0" => :sierra
    sha256 "92efa66cd268f0447dc52c14e9da04ae8af01b1691ec8eec3df61bbeb947b713" => :el_capitan
    sha256 "bb2aefa17b699127f2f6ed65004c9acbf7e5e5122f6f4b920d1e03fb9bd87b2e" => :yosemite
    sha256 "ae3c4b14dd19d3ac43947eff025a0fa3eabbe832333922359f9f74e0fe5e1d3d" => :mavericks
    sha256 "408c2744b730a01eed68f19d4f643b060f026bbbc2616cf4b6afcb08ef608b90" => :mountain_lion
    sha256 "d73265ee08abb832ea596ab7d6a441c7aa5c45630387c77e99d6571f3493c88a" => :x86_64_linux
  end

  depends_on "ghostscript"
  fails_with :gcc => "4.8"

  def install
    ENV.deparallelize
    system "make", "install",
                   "EPSTOOL_ROOT=#{prefix}",
                   "EPSTOOL_MANDIR=#{man}",
                   "CC=#{ENV.cc}"
  end

  test do
    system bin/"epstool", "--add-tiff-preview", "--device", "tiffg3", test_fixtures("test.eps"), "test2.eps"
    assert File.exist?("test2.eps")
  end
end
