class ShadowsocksLibev < Formula
  desc "Libev port of shadowsocks"
  homepage "https://github.com/shadowsocks/shadowsocks-libev"
  url "https://github.com/shadowsocks/shadowsocks-libev/releases/download/v3.1.0/shadowsocks-libev-3.1.0.tar.gz"
  sha256 "3b6493ebdcfff1eb31faf34d164d57049f7253ff5bffafa6ce2263c9ac123f31"
  revision 1

  bottle do
    cellar :any
    sha256 "1994261a8970969ff3d8ff982079bb2f69983b63780b64d6428398d1216add3a" => :high_sierra
    sha256 "8ee9172421c38c05d2691ee365f8e853c5742878315572f5e3d83ca4fbef50de" => :sierra
    sha256 "645c05ca758700622d49cb89c4ea8ec81c17953397fb462a36541fc9211d35ad" => :el_capitan
    sha256 "f407438a487b2d96cc263e53e1405c97c48463b42216dbfbd1e4429e60677ddd" => :x86_64_linux
  end

  depends_on "asciidoc" => :build
  depends_on "xmlto" => :build
  depends_on "c-ares"
  depends_on "libev"
  depends_on "libsodium"
  depends_on "mbedtls"
  depends_on "pcre"

  def install
    ENV["XML_CATALOG_FILES"] = etc/"xml/catalog"

    system "./configure", "--prefix=#{prefix}"
    system "make"

    (buildpath/"shadowsocks-libev.json").write <<~EOS
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

  plist_options :manual => "#{HOMEBREW_PREFIX}/opt/shadowsocks-libev/bin/ss-local -c #{HOMEBREW_PREFIX}/etc/shadowsocks-libev.json -u"

  def plist; <<~EOS
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
          <string>-u</string>
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
    (testpath/"shadowsocks-libev.json").write <<~EOS
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
