class Nuspell < Formula
  desc "Spell checker"
  homepage "https://nuspell.github.io"
  url "https://github.com/nuspell/nuspell/archive/v3.0.0.tar.gz"
  sha256 "9ce86d5463723cc7dceba9d1dd046e1022ed5e3004ac6d12f2daaf5b090a6066"

  depends_on "catch2" => :build
  depends_on "cmake" => :build
  depends_on "gcc@7" => :build
  depends_on "ruby" => :build
  depends_on "boost"
  depends_on "icu4c"
  fails_with :gcc => "5"
  fails_with :gcc => "6"

  def install
    mkdir "build" do
      ENV["GEM_HOME"] = buildpath/"gem_home"
      system "gem", "install", "ronn"
      ENV.prepend_path "PATH", buildpath/"gem_home/bin"
      system "cmake", "..", "-DBUILD_SHARED_LIBS=ON", *std_cmake_args
      system "cmake", "--build", "."
      system "cmake", "--build", ".", "--target", "test"
      system "cmake", "--build", ".", "--target", "install"
    end
  end

  def caveats; <<~EOS
    Dictionary files (*.aff and *.dic) should be placed in
    ~/Library/Spelling/ or /Library/Spelling/.  Homebrew itself
    provides no dictionaries for Nuspell, but you can download
    compatible dictionaries from other sources, such as
    https://wiki.documentfoundation.org/Language_support_of_LibreOffice .
  EOS
  end

  test do
    system bin/"nuspell", "--help"
  end
end
