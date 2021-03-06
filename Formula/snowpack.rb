require "language/node"

class Snowpack < Formula
  desc "Frontend build tool designed for the modern web"
  homepage "https://www.snowpack.dev"
  url "https://registry.npmjs.org/snowpack/-/snowpack-3.8.1.tgz"
  sha256 "a183c004b110812d40fdf1b42191e4a6e04ea0c5b3d15ecacf5951002c30bfd9"
  license "MIT"

  bottle do
    sha256                               arm64_big_sur: "1a986c232f3ae3acd7a006c9dd66354a0f359e685fdbb13432ec00a9ee523101"
    sha256                               big_sur:       "e67c8787225acd6e90f1b1fb601e47e94af118bd3afd2919d9a57cd7d77d25ba"
    sha256                               catalina:      "b2d8932ee5c675e8b04b2474d2c905124c97dfc091d7644c4d23a6d942d37bb0"
    sha256                               mojave:        "0705663ca929e776e3a60de5a43f057b5d1831d685a63fa4a9d6004fd1dd1cf5"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "83d15cb787248eb73bf918123785bb9000ef2d1c662bef613abbe5885d0de938" # linuxbrew-core
  end

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    mkdir "work" do
      system "npm", "init", "-y"
      system bin/"snowpack", "init"
      assert_predicate testpath/"work/snowpack.config.js", :exist?

      inreplace testpath/"work/snowpack.config.js",
        "  packageOptions: {\n    /* ... */\n  },",
        "  packageOptions: {\n    source: \"remote\"\n  },"
      system bin/"snowpack", "add", "react"
      deps_contents = File.read testpath/"work/snowpack.deps.json"
      assert_match(/\s*"dependencies":\s*{\s*"react": ".*"\s*}/, deps_contents)

      assert_match "Build Complete", shell_output("#{bin}/snowpack build")
    end
  end
end
