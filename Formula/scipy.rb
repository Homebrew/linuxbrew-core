class Scipy < Formula
  desc "Software for mathematics, science, and engineering"
  homepage "https://www.scipy.org"
  url "https://github.com/scipy/scipy/releases/download/v0.19.1/scipy-0.19.1.tar.xz"
  sha256 "0dca04c4860afdcb066cab4fd520fcffa8c85e9a7b5aa37a445308e899d728b3"
  revision 1
  head "https://github.com/scipy/scipy.git"

  bottle do
    sha256 "8d012bce51f0329e4da5d9746d7651aedf16d3d4859421060cf7b7510234ed42" => :high_sierra
    sha256 "52dfdefbaeaaeb843ae2f36a7e743ccdb69d3eecd266d7a27ab2693c8e15be06" => :sierra
    sha256 "6a7138aa35a3a58e6f4ba77946e3dec4a6ca6f4456cbc31b8e23a7e5ae8ad3b4" => :el_capitan
    sha256 "5b793bffbedc74ba881866847a02cefa02dc1372ff22ce86920fe68fc44c25b2" => :yosemite
    sha256 "0ee89841db192b63fcc68af006e54244ea0ace89a388178bbcc436dc0cc104a2" => :x86_64_linux # glibc 2.19
  end

  option "without-python", "Build without python2 support"

  depends_on "swig" => :build
  depends_on :fortran
  depends_on "numpy"
  depends_on :python => :recommended if MacOS.version <= :snow_leopard || !OS.mac?
  depends_on :python3 => :recommended
  depends_on "openblas" unless OS.mac?

  cxxstdlib_check :skip

  # https://github.com/Homebrew/homebrew-python/issues/110
  # There are ongoing problems with gcc+accelerate.
  fails_with :gcc

  # Avoid the error: undefined reference to `main'
  env :super if OS.linux?

  def install
    config = <<~EOS
      [DEFAULT]
      library_dirs = #{HOMEBREW_PREFIX}/lib
      include_dirs = #{HOMEBREW_PREFIX}/include
    EOS

    Pathname("site.cfg").write config

    # gfortran is gnu95
    Language::Python.each_python(build) do |python, version|
      ENV["PYTHONPATH"] = Formula["numpy"].opt_lib/"python#{version}/site-packages"
      ENV.prepend_create_path "PYTHONPATH", lib/"python#{version}/site-packages"
      system python, "setup.py", "build", "--fcompiler=gnu95"
      system python, *Language::Python.setup_install_args(prefix)
    end
  end

  # cleanup leftover .pyc files from previous installs which can cause problems
  # see https://github.com/Homebrew/homebrew-python/issues/185#issuecomment-67534979
  def post_install
    Language::Python.each_python(build) do |_python, version|
      rm_f Dir["#{HOMEBREW_PREFIX}/lib/python#{version}/site-packages/scipy/**/*.pyc"]
    end
  end

  def caveats
    if (build.with? "python") && !Formula["python"].installed?
      homebrew_site_packages = Language::Python.homebrew_site_packages
      user_site_packages = Language::Python.user_site_packages "python"
      <<~EOS
        If you use system python (that comes - depending on the OS X version -
        with older versions of numpy, scipy and matplotlib), you may need to
        ensure that the brewed packages come earlier in Python's sys.path with:
          mkdir -p #{user_site_packages}
          echo 'import sys; sys.path.insert(1, "#{homebrew_site_packages}")' >> #{user_site_packages}/homebrew.pth
      EOS
    end
  end

  test do
    Language::Python.each_python(build) do |python, _version|
      system python, "-c", "import scipy"
    end
  end
end
