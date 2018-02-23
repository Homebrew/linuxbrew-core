class Fig2dev < Formula
  desc "Translates figures generated by xfig to other formats"
  homepage "https://mcj.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/mcj/fig2dev-3.2.6a.tar.xz"
  sha256 "5e61a3d9a4f83db4b3199ee82dd54bb65b544369f1e8e38a2606c44cf71667a7"
  revision OS.mac? ? 1 : 2

  bottle do
    sha256 "b1f95cc8188a385a88c14afc52eebdda27ee5a8e1d7cb5140c856a5ed2ca54ca" => :high_sierra
    sha256 "faf054ca4097373006a95bde74efc792a663bc19f34f2f9cb59eac67c9f96740" => :sierra
    sha256 "703e5bba6e0a413f865e6f34fb8ecc92ff64dd9469ae761947a1b0b707c4a4a9" => :el_capitan
    sha256 "6994cc58bcf98e205b0d3d6ebbefbe2d7bcc02db84c10440a0e1c421fc08a79f" => :yosemite
  end

  depends_on "ghostscript"
  depends_on "libpng"
  depends_on :x11 => :optional
  depends_on "linuxbrew/xorg/xorg" if build.with?("x11") && !OS.mac?

  # Upstream issue "macOS build fails without XQuartz (fig2dev 3.2.6a)"
  # Reported 15 Aug 2017 https://sourceforge.net/p/mcj/tickets/15/
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/ace42c9/fig2dev/fig2dev-no-x11.patch"
    sha256 "0fff7d54cc29c280f3bfa3ede9febdd7158bc923d3e7fe71a1706a1b9ed5c0ee"
  end

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --enable-transfig
    ]

    if build.with? "x11"
      args << "--with-xpm" << "--with-x"
    else
      args << "--without-xpm" << "--without-x"
    end

    system "./configure", *args
    system "make", "install"

    # Install a fig file for testing
    pkgshare.install "fig2dev/tests/data/patterns.fig"
  end

  test do
    system "#{bin}/fig2dev", "-L", "png", "#{pkgshare}/patterns.fig", "patterns.png"
    assert_predicate testpath/"patterns.png", :exist?, "Failed to create PNG"
  end
end
