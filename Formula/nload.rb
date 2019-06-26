class Nload < Formula
  desc "Realtime console network usage monitor"
  homepage "http://www.roland-riegel.de/nload/"
  url "http://www.roland-riegel.de/nload/nload-0.7.4.tar.gz"
  sha256 "c1c051e7155e26243d569be5d99c744d8620e65fa8a7e05efcf84d01d9d469e5"

  bottle do
    sha256 "860516b22b47a979243b87da6fca2b3e60688f127b9f97bafdb90cd157e57812" => :mojave
    sha256 "220cc0307d6b1548af61b2cd70236da4c5f403a96a12e941278689ec802d9431" => :high_sierra
    sha256 "086ab214598a7a3b6db19eb1f2ddd6a646f292866d42661bc6c29c283c1b7495" => :sierra
    sha256 "dd23e0631ece0bc06328be086993d030c8bf4e99d29898e59eb0e6f546c44990" => :el_capitan
    sha256 "465b4d813588821d240dce65ffc46bc67d55f64044a26a33b5a49b810deea7f8" => :yosemite
    sha256 "344b909ee8033a4ab27c1db04e9505b0bbf6d0141f391c470cc36b33e6dd7723" => :mavericks
    sha256 "19ad7b6cb1dd6c7a7fc93c09eea618adc56dc519de3d11586a7010a19722af8b" => :x86_64_linux
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  uses_from_macos "ncurses"

  # crash on F2 and garbage in adapter name, see https://sourceforge.net/p/nload/bugs/8/ reported on 2014-04-03
  patch :p0 do
    url "https://sourceforge.net/p/nload/bugs/_discuss/thread/c9b68d8e/4a65/attachment/devreader-bsd.cpp.patch"
    sha256 "19055158b72722f7dabff9890931094cac591bcc6de3e90a7f4744d28746ebc7"
  end

  # Patching configure.in file to make configure compile on Mac OS.
  # Patch taken from MacPorts.
  patch :DATA

  def install
    system "./run_autotools"
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    # Unset LDFLAGS, "-s" causes the linker to crash
    system "make", "install", "LDFLAGS="
  end

  test do
    system "#{bin}/nload", "--help"
  end
end


__END__
diff --git a/configure.in b/configure.in
index 87ecc88..4df8dc3 100644
--- a/configure.in
+++ b/configure.in
@@ -38,7 +38,7 @@ case $host_os in
 
         AC_CHECK_FUNCS([memset])
         ;;
-    *bsd*)
+    *darwin*)
         AC_DEFINE(HAVE_BSD, 1, [Define to 1 if your build target is BSD.])
         AM_CONDITIONAL(HAVE_BSD, true)
