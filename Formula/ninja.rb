class Ninja < Formula
  desc "Small build system for use with gyp or CMake"
  homepage "https://ninja-build.org/"
  url "https://github.com/ninja-build/ninja/archive/v1.10.0.tar.gz"
  sha256 "3810318b08489435f8efc19c05525e80a993af5a55baa0dfeae0465a9d45f99f"
  license "Apache-2.0"
  revision 1 unless OS.mac?
  head "https://github.com/ninja-build/ninja.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "b536415ef20ab14e808ef3fe558bbcd4c86de048d7e47cc86906fed4e1507fdc" => :catalina
    sha256 "07c7d5eab06643969950a168b7a4ce34a39d236869e909942294eb136dfe3063" => :mojave
    sha256 "e413c88eed509424d118a0b61b7b3c63535fc7c8c92cd336322db7a8af9cf6e0" => :high_sierra
    sha256 "ddec6959492b9366a5f53660885844e66465338563a79c5e1d386459be44e92e" => :x86_64_linux
  end

  depends_on "python@3.8" => :build unless OS.mac?

  def install
    ENV.prepend_path "PATH", Formula["python@3.8"].opt_libexec/"bin" unless OS.mac?

    system "python", "configure.py", "--bootstrap"

    # Quickly test the build
    system "./configure.py"
    system "./ninja", "ninja_test"
    system "./ninja_test", "--gtest_filter=-SubprocessTest.SetWithLots"

    bin.install "ninja"
    bash_completion.install "misc/bash-completion" => "ninja-completion.sh"
    zsh_completion.install "misc/zsh-completion" => "_ninja"
  end

  test do
    (testpath/"build.ninja").write <<~EOS
      cflags = -Wall

      rule cc
        command = gcc $cflags -c $in -o $out

      build foo.o: cc foo.c
    EOS
    system bin/"ninja", "-t", "targets"
  end
end
