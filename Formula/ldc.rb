class Ldc < Formula
  desc "Portable D programming language compiler"
  homepage "https://wiki.dlang.org/LDC"
  url "https://github.com/ldc-developers/ldc/releases/download/v1.17.0/ldc-1.17.0-src.tar.gz"
  sha256 "6a2fa91a53d954361832591488241c92adb497842069077425d73c9b9d2c4fa9"
  head "https://github.com/ldc-developers/ldc.git", :shallow => false

  bottle do
    cellar :any_skip_relocation
    sha256 "d1a3c150b95503558ef83d8e6dfdad818fa550b97333368178e402ab13cc02fc" => :mojave
    sha256 "ae7b85fa800d95dcc8815dfafd5716b0d3cf47134d2fc536a2796db8cee11f28" => :high_sierra
    sha256 "f48a3181863ba8a69c56459512a15fb1f0fcc153250d3cba5374c173a3627d31" => :sierra
  end

  depends_on "cmake" => :build
  depends_on "libconfig" => :build
  depends_on "llvm"
  depends_on "pkg-config" => :build unless OS.mac?

  resource "ldc-bootstrap" do
    if OS.mac?
      url "https://github.com/ldc-developers/ldc/releases/download/v1.17.0/ldc2-1.17.0-osx-x86_64.tar.xz"
      version "1.17.0"
      sha256 "fb1fe4e6edba4a8ac590e24abccdd034f11fa11a1bbe4c0f3cdb6083ba069825"
    else
      url "https://github.com/ldc-developers/ldc/releases/download/v1.17.0/ldc2-1.17.0-linux-x86_64.tar.xz"
      version "1.17.0"
      sha256 "715adbdd614edf926d5f53bb9f8bfa34d0c828aa40077cb627ce064955fd641d"
    end
  end

  def install
    # Fix the error:
    # CMakeFiles/LDCShared.dir/build.make:68: recipe for target 'dmd2/id.h' failed
    ENV.deparallelize unless OS.mac?

    ENV.cxx11
    (buildpath/"ldc-bootstrap").install resource("ldc-bootstrap")

    mkdir "build" do
      args = std_cmake_args + %W[
        -DLLVM_ROOT_DIR=#{Formula["llvm"].opt_prefix}
        -DINCLUDE_INSTALL_DIR=#{include}/dlang/ldc
        -DD_COMPILER=#{buildpath}/ldc-bootstrap/bin/ldmd2
        -DLDC_WITH_LLD=OFF
        -DRT_ARCHIVE_WITH_LDC=OFF
      ]
      # LDC_WITH_LLD see https://github.com/ldc-developers/ldc/releases/tag/v1.4.0 Known issues
      # RT_ARCHIVE_WITH_LDC see https://github.com/ldc-developers/ldc/issues/2350

      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    (testpath/"test.d").write <<~EOS
      import std.stdio;
      void main() {
        writeln("Hello, world!");
      }
    EOS
    system bin/"ldc2", "test.d"
    assert_match "Hello, world!", shell_output("./test")
    # Fix Error: The LLVMgold.so plugin (needed for LTO) was not found.
    if OS.mac?
      system bin/"ldc2", "-flto=thin", "test.d"
      assert_match "Hello, world!", shell_output("./test")
      system bin/"ldc2", "-flto=full", "test.d"
      assert_match "Hello, world!", shell_output("./test")
    end
    system bin/"ldmd2", "test.d"
    assert_match "Hello, world!", shell_output("./test")
  end
end
