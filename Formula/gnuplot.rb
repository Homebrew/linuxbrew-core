# gnuplot: Build a bottle for Linuxbrew
class Gnuplot < Formula
  desc "Command-driven, interactive function plotting"
  homepage "http://www.gnuplot.info"
  url "https://downloads.sourceforge.net/project/gnuplot/gnuplot/5.0.5/gnuplot-5.0.5.tar.gz"
  sha256 "25f3e0bf192e01115c580f278c3725d7a569eb848786e12b455a3fda70312053"
  revision 1

  bottle do
    sha256 "9a45029ee03f7011ac9dace9cd22854fed5badb788dceb2043a4d5412e2d9a0b" => :sierra
    sha256 "9ba16e37310ace0de6a97d81f21bd9d4e0d2c79e1ee750a3bf3b9b926a20a684" => :el_capitan
    sha256 "95da509dc600150780651cf34f62cd524ff065b833fff119617e5d0e61e3e215" => :yosemite
  end

  head do
    url ":pserver:anonymous:@gnuplot.cvs.sourceforge.net:/cvsroot/gnuplot", :using => :cvs

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  option "with-cairo", "Build the Cairo based terminals"
  option "without-lua", "Build without the lua/TikZ terminal"
  option "with-test", "Verify the build with make check"
  option "with-wxmac", "Build wxmac support. Need with-cairo to build wxt terminal"
  option "with-tex", "Build with LaTeX support"
  option "with-aquaterm", "Build with AquaTerm support"

  deprecated_option "with-x" => "with-x11"
  deprecated_option "pdf" => "with-pdflib-lite"
  deprecated_option "wx" => "with-wxmac"
  deprecated_option "qt" => "with-qt@5.7"
  deprecated_option "with-qt" => "with-qt@5.7"
  deprecated_option "with-qt5" => "with-qt@5.7"
  deprecated_option "cairo" => "with-cairo"
  deprecated_option "nolua" => "without-lua"
  deprecated_option "tests" => "with-test"
  deprecated_option "with-tests" => "with-test"
  deprecated_option "latex" => "with-tex"
  deprecated_option "with-latex" => "with-tex"

  depends_on "pkg-config" => :build
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "gd"
  depends_on "lua" => :recommended
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "readline"
  depends_on "webp"
  depends_on "pango" if build.with?("cairo") || build.with?("wxmac")
  depends_on "pdflib-lite" => :optional
  depends_on "qt@5.7" => :optional
  depends_on "wxmac" => :optional
  depends_on :tex => :optional
  depends_on :x11 => :optional

  needs :cxx11 if build.with? "qt@5.7"

  def install
    # Qt5 requires c++11 (and the other backends do not care)
    ENV.cxx11 if build.with? "qt@5.7"

    if build.with? "aquaterm"
      # Add "/Library/Frameworks" to the default framework search path, so that an
      # installed AquaTerm framework can be found. Brew does not add this path
      # when building against an SDK (Nov 2013).
      ENV.prepend "CPPFLAGS", "-F/Library/Frameworks"
      ENV.prepend "LDFLAGS", "-F/Library/Frameworks"
    end

    # Help configure find libraries
    pdflib = Formula["pdflib-lite"].opt_prefix

    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --with-readline=#{Formula["readline"].opt_prefix}
    ]

    args << "--with-pdf=#{pdflib}" if build.with? "pdflib-lite"

    if build.without? "wxmac"
      args << "--disable-wxwidgets"
      args << "--without-cairo" if build.without? "cairo"
    end

    if build.with? "qt@5.7"
      args << "--with-qt"
    else
      args << "--with-qt=no"
    end

    # The tutorial requires the deprecated subfigure TeX package installed
    # or it halts in the middle of the build for user-interactive resolution.
    # Per upstream: "--with-tutorial is horribly out of date."
    args << "--without-tutorial"
    args << "--without-lua" if build.without? "lua"
    args << ((build.with? "aquaterm") ? "--with-aquaterm" : "--without-aquaterm")
    args << ((build.with? "x11") ? "--with-x" : "--without-x")

    if build.with? "tex"
      args << "--with-latex"
    else
      args << "--without-latex"
    end

    system "./prepare" if build.head?
    system "./configure", *args
    ENV.deparallelize # or else emacs tries to edit the same file with two threads
    system "make"
    system "make", "check" if build.with?("test") || build.bottle?
    system "make", "install"
  end

  def caveats
    if build.with? "aquaterm"
      <<-EOS.undent
        AquaTerm support will only be built into Gnuplot if the standard AquaTerm
        package from SourceForge has already been installed onto your system.
        If you subsequently remove AquaTerm, you will need to uninstall and then
        reinstall Gnuplot.
      EOS
    end
  end

  test do
    system "#{bin}/gnuplot", "-e", <<-EOS.undent
      set terminal png;
      set output "#{testpath}/image.png";
      plot sin(x);
    EOS
    File.exist? testpath/"image.png"
  end
end
