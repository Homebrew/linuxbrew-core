class JdkDownloadStrategy < CurlDownloadStrategy
  def _curl_opts
    super << "--cookie" << "oraclelicense=accept-securebackup-cookie"
  end
end

class Jdk < Formula
  desc "Java Platform, Standard Edition Development Kit (JDK)."
  homepage "http://www.oracle.com/technetwork/java/javase/downloads/index.html"
  # tag "linuxbrew"

  version "9+181"
  if OS.linux?
    url "http://download.oracle.com/otn-pub/java/jdk/9+181/jdk-9_linux-x64_bin.tar.gz",
      :using => JdkDownloadStrategy
    sha256 "1c6d783a54fcc0673ed1f8c5e8650b1d8977ca3e856a03fba0090198e0f16f6d"
  elsif OS.mac?
    url "http://java.com/"
  end

  bottle do
    cellar :any_skip_relocation
    sha256 "070e1f7f815a13e304d1a1e4c0ced85e2eee8c2a0c006bd3a06c6c4e58a7e6ee" => :x86_64_linux # glibc 2.19
  end

  def install
    odie "Use 'brew cask install java' on Mac OS" if OS.mac?
    prefix.install Dir["*"]
  end

  def caveats; <<-EOS.undent
    By installing and using JDK you agree to the
    Oracle Binary Code License Agreement for the Java SE Platform Products and JavaFX
    http://www.oracle.com/technetwork/java/javase/terms/license/index.html
    EOS
  end

  test do
    (testpath/"Hello.java").write <<-EOS.undent
      class Hello
      {
        public static void main(String[] args)
        {
          System.out.println("Hello Homebrew");
        }
      }
    EOS
    system bin/"javac", "Hello.java"
    assert_predicate testpath/"Hello.class", :exist?, "Failed to compile Java program!"
    assert_equal "Hello Homebrew\n", shell_output("#{bin}/java Hello")
  end
end
