class Libmypaint < Formula
  desc "MyPaint brush engine library"
  homepage "https://github.com/mypaint/libmypaint/wiki"
  url "https://github.com/mypaint/libmypaint/releases/download/v1.6.1/libmypaint-1.6.1.tar.xz"
  sha256 "741754f293f6b7668f941506da07cd7725629a793108bb31633fb6c3eae5315f"
  revision 1

  bottle do
    cellar :any
    sha256 "699014970a67055822e7ee2abc92c4ea2b45e51bcd58cfa01cb24c2ed08f6a2b" => :catalina
    sha256 "97ca6e5c0ae27513cc3af20c1256548d6a21e0a38bfdcea5a79f7fe1c0a6886d" => :mojave
    sha256 "4260697ececf5344aa3eacd16afdd5f4eff556cee6312e49a8e5544edb71aca1" => :high_sierra
  end

  depends_on "intltool" => :build
  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "json-c"

  def install
    system "./configure", "--disable-introspection",
                          "--without-glib",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <mypaint-brush.h>
      int main() {
        MyPaintBrush *brush = mypaint_brush_new();
        mypaint_brush_unref(brush);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}/libmypaint", "-L#{lib}", "-lmypaint", "-o", "test"
    system "./test"
  end
end
