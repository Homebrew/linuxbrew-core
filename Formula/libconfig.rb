class Libconfig < Formula
  desc "Configuration file processing library"
  homepage "https://www.hyperrealm.com/libconfig/"
  url "https://github.com/hyperrealm/libconfig/archive/v1.6.tar.gz"
  sha256 "18739792eb463d73525d7aea9b0a48b14106fae1cfec09aedc668d8c1079adf1"

  bottle do
    cellar :any
    sha256 "76c392efe1620331e9840eb426d9551c15f0c1f5b3db6bd255f7a6f7d28a70ec" => :sierra
    sha256 "b761558d36680478ea69e888a35bb64df066a561f9534e9b893b26e07a4062e4" => :el_capitan
    sha256 "da3783f62333e9f65b235c7359de96264476e7bb7a0e472f7f81d288cbd059ec" => :yosemite
    sha256 "dfb06c8602d8cb3a81a0d63127fc45c112bbdd494772f5ce50715f06383d596d" => :mavericks
    sha256 "4c66dc28067e2413541c79addf46cdc2def7d9537536c0f8a56b174e0644ec7d" => :x86_64_linux # glibc 2.19
  end

  head do
    url "https://github.com/hyperrealm/libconfig.git"
    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
  end

  unless OS.mac?
    depends_on "flex" => :build
    depends_on "texinfo" => :build
  end

  def install
    system "autoreconf", "-i" if build.head?
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"

    # Fixes "scanner.l:137:59: error: too few arguments to function call ..."
    # Forces regeneration of the BUILT_SOURCES "scanner.c" and "scanner.h"
    # Reported 6 Jun 2016: https://github.com/hyperrealm/libconfig/issues/66
    touch "lib/scanner.l"

    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <libconfig.h>
      int main() {
        config_t cfg;
        config_init(&cfg);
        config_destroy(&cfg);
        return 0;
      }
    EOS
    system ENV.cc, "-I#{include}", "-L#{lib}",
           testpath/"test.c", "-lconfig", "-o", testpath/"test"
    system "./test"
  end
end
