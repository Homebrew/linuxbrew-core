class Cxxtest < Formula
  desc "xUnit-style unit testing framework for C++"
  homepage "http://cxxtest.com"
  url "https://github.com/CxxTest/cxxtest/releases/download/4.4/cxxtest-4.4.tar.gz"
  mirror "https://mirrors.kernel.org/debian/pool/main/c/cxxtest/cxxtest_4.4.orig.tar.gz"
  sha256 "1c154fef91c65dbf1cd4519af7ade70a61d85a923b6e0c0b007dc7f4895cf7d8"

  bottle do
    cellar :any_skip_relocation
    sha256 "b6016aba933e8e047299e4a4dae83549eb8679a9e18e11937d90877b9e94af62" => :high_sierra
    sha256 "09aa93c60544867a44c3ad711f7ad9207f3f097505ce658e12d4d8ae11287c82" => :sierra
    sha256 "d35cfbbea5de989734e9f859531b203dffc870fdf931a5a7f12302adc7354c87" => :el_capitan
    sha256 "a69d95d4c027024e6c14a999c679106cf6259e22bb748205d93dbc5d0596a8e3" => :yosemite
    sha256 "2e8e487aac953d698f38f89ae9946572f8d072ec35b91683aa66bc147cec2fa4" => :mavericks
    sha256 "de1e98e94198507c65ecb17ae240b995ae8f03dadeafbde27bb704df2e10737c" => :mountain_lion
    sha256 "6ae4f59bfb97934f5de0477c1d6b9da286ab6ad444b7db6af8051272fb204799" => :x86_64_linux # glibc 2.19
  end

  depends_on :python if MacOS.version <= :snow_leopard

  def install
    ENV["PYTHONPATH"] = lib+"python2.7/site-packages"
    ENV.prepend_create_path "PYTHONPATH", lib+"python2.7/site-packages"

    cd "./python" do
      system "python", *Language::Python.setup_install_args(prefix)
    end

    bin.env_script_all_files(libexec+"bin", :PYTHONPATH => ENV["PYTHONPATH"])

    include.install "cxxtest"
    doc.install Dir["doc/*"]
  end

  test do
    testfile = testpath/"MyTestSuite1.h"
    testfile.write <<~EOS
      #include <cxxtest/TestSuite.h>

      class MyTestSuite1 : public CxxTest::TestSuite {
      public:
          void testAddition(void) {
              TS_ASSERT(1 + 1 > 1);
              TS_ASSERT_EQUALS(1 + 1, 2);
          }
      };
    EOS

    system bin/"cxxtestgen", "--error-printer", "-o", testpath/"runner.cpp", testfile
    system ENV.cxx, "-o", testpath/"runner", testpath/"runner.cpp"
    system testpath/"runner"
  end
end
