# shadowsocks-libev: Build a bottle for Linuxbrew
class ShadowsocksLibev < Formula
  desc "Libev port of shadowsocks"
  homepage "https://github.com/shadowsocks/shadowsocks-libev"
  url "https://github.com/shadowsocks/shadowsocks-libev/releases/download/v3.1.0/shadowsocks-libev-3.1.0.tar.gz"
  sha256 "3b6493ebdcfff1eb31faf34d164d57049f7253ff5bffafa6ce2263c9ac123f31"

  bottle do
    cellar :any
    sha256 "9dc98453a95b5f00f659167fd1cbf169e33e3672555a73e5bd3a2d553129b94b" => :high_sierra
    sha256 "a916884173ccc51afbb830d03b36447880883608cd4f9642d252955757208a0a" => :sierra
    sha256 "2bb3de97af9ceeb9ba70c9183c76112375fc177071bdf2b4eacce7089da405d1" => :el_capitan
    sha256 "38a51346e6b420200705f12bba73fb6b7980d258560c6712ed2904c508504d79" => :x86_64_linux
  end

  depends_on "asciidoc" => :build
  depends_on "xmlto" => :build
  depends_on "c-ares"
  depends_on "libev"
  depends_on "libsodium"
  depends_on "mbedtls"
  depends_on "pcre"
  depends_on "udns"

  def install
    ENV["XML_CATALOG_FILES"] = etc/"xml/catalog"

    system "./configure", "--prefix=#{prefix}"
    system "make"

    (buildpath/"shadowsocks-libev.json").write <<-EOS.undent
      {
          "server":"localhost",
          "server_port":8388,
          "local_port":1080,
          "password":"barfoo!",
          "timeout":600,
          "method":null
      }
    EOS
    etc.install "shadowsocks-libev.json"

    inreplace Dir["man/*"], "/etc/shadowsocks-libev/config.json", "#{etc}/shadowsocks-libev.json"

    system "make", "install"
  end

  plist_options :manual => "#{HOMEBREW_PREFIX}/opt/shadowsocks-libev/bin/ss-local -c #{HOMEBREW_PREFIX}/etc/shadowsocks-libev.json"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/ss-local</string>
          <string>-c</string>
          <string>#{etc}/shadowsocks-libev.json</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <true/>
      </dict>
    </plist>
    EOS
  end

  test do
    (testpath/"shadowsocks-libev.json").write <<-EOS.undent
      {
          "server":"127.0.0.1",
          "server_port":9998,
          "local":"127.0.0.1",
          "local_port":9999,
          "password":"test",
          "timeout":600,
          "method":null
      }
    EOS
    server = fork { exec bin/"ss-server", "-c", testpath/"shadowsocks-libev.json" }
    client = fork { exec bin/"ss-local", "-c", testpath/"shadowsocks-libev.json" }
    sleep 3
    begin
      system "curl", "--socks5", "127.0.0.1:9999", "github.com"
    ensure
      Process.kill 9, server
      Process.wait server
      Process.kill 9, client
      Process.wait client
    end
  end
end
