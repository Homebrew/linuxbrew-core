class Leiningen < Formula
  desc "Build tool for Clojure"
  homepage "https://github.com/technomancy/leiningen"
  url "https://github.com/technomancy/leiningen/archive/2.8.0.tar.gz"
  sha256 "c02919055d23420a919f9a133457d49fd85141565e24bc2c45c1ec1ad6c11bec"
  head "https://github.com/technomancy/leiningen.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "9a00b911bef1efeff0330b0bba8c767ea0085296f183c6a47322773db007c517" => :high_sierra
    sha256 "9a00b911bef1efeff0330b0bba8c767ea0085296f183c6a47322773db007c517" => :sierra
    sha256 "9a00b911bef1efeff0330b0bba8c767ea0085296f183c6a47322773db007c517" => :el_capitan
    sha256 "f1edff33d46f10b815e5b87efb0d6aa8d6c18dba07caca9b5a97ee50a1b95df3" => :x86_64_linux
  end

  resource "jar" do
    url "https://github.com/technomancy/leiningen/releases/download/2.8.0/leiningen-2.8.0-standalone.zip", :using => :nounzip
    sha256 "69c8c553553d1e02ca89bfa2a7650acf80b75511d193bfaa60236342e1356075"
  end

  def install
    jar = "leiningen-#{version}-standalone.jar"
    resource("jar").stage do
      libexec.install "leiningen-#{version}-standalone.zip" => jar
    end

    # bin/lein autoinstalls and autoupdates, which doesn't work too well for us
    inreplace "bin/lein-pkg" do |s|
      s.change_make_var! "LEIN_JAR", libexec/jar
    end

    bin.install "bin/lein-pkg" => "lein"
    bash_completion.install "bash_completion.bash" => "lein-completion.bash"
    zsh_completion.install "zsh_completion.zsh" => "_lein"
  end

  def caveats; <<~EOS
    Dependencies will be installed to:
      $HOME/.m2/repository
    To play around with Clojure run `lein repl` or `lein help`.
    EOS
  end

  test do
    (testpath/"project.clj").write <<~EOS
      (defproject brew-test "1.0"
        :dependencies [[org.clojure/clojure "1.5.1"]])
    EOS
    (testpath/"src/brew_test/core.clj").write <<~EOS
      (ns brew-test.core)
      (defn adds-two
        "I add two to a number"
        [x]
        (+ x 2))
    EOS
    (testpath/"test/brew_test/core_test.clj").write <<~EOS
      (ns brew-test.core-test
        (:require [clojure.test :refer :all]
                  [brew-test.core :as t]))
      (deftest canary-test
        (testing "adds-two yields 4 for input of 2"
          (is (= 4 (t/adds-two 2)))))
    EOS
    system "#{bin}/lein", "test"
  end
end
