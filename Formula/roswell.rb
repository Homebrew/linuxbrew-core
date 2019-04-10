class Roswell < Formula
  desc "Lisp installer and launcher for major environments"
  homepage "https://github.com/roswell/roswell"
  url "https://github.com/roswell/roswell/archive/v19.4.10.98.tar.gz"
  sha256 "5783431ef096840dd5696b448c76e66e8805e53bd7ac6fb572734e3ffd969649"
  head "https://github.com/roswell/roswell.git"

  bottle do
    sha256 "29df3dec523805cf59a014ed724a03b98138484588a16d0ffc3188386e310a98" => :mojave
    sha256 "df711291567a25e3a1783bfe9e05e44e8ba7aaf522b0aae6ba1314c974ec06ac" => :high_sierra
    sha256 "eecd79e1aca9544139fea027739229787b4976f70b14f46f78df310c0ba68ada" => :sierra
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "curl" unless OS.mac?

  def install
    system "./bootstrap"
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    ENV["ROSWELL_HOME"] = testpath
    system bin/"ros", "init"
    assert_predicate testpath/"config", :exist?
  end
end
