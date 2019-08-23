class Postgresql < Formula
  desc "Object-relational database system"
  homepage "https://www.postgresql.org/"
  url "https://ftp.postgresql.org/pub/source/v11.5/postgresql-11.5.tar.bz2"
  sha256 "7fdf23060bfc715144cbf2696cf05b0fa284ad3eb21f0c378591c6bca99ad180"
  head "https://github.com/postgres/postgres.git"

  bottle do
    sha256 "fb07943cee2493f3bfaf94773f36b4ffbd635d0d38008587222a6f722f2a1c3e" => :mojave
    sha256 "553298bb9502d8dea410190ff1ffbbdbed123c2d654014e0c6f5509332f0272d" => :high_sierra
    sha256 "e11d6a1255b1c4f52e9014d13c2bc8be502ccd795e3275365344c810ef548880" => :sierra
    sha256 "ff42330589e53467ccdbae2587fad82cf71f0e56363fb1a2c956cc2a22e29f89" => :x86_64_linux
  end

  depends_on "pkg-config" => :build
  depends_on "icu4c"
  depends_on "openssl"
  depends_on "readline"
  unless OS.mac?
    depends_on "libxslt"
    depends_on "perl"
    depends_on "util-linux" # for libuuid
  end

  conflicts_with "postgres-xc",
    :because => "postgresql and postgres-xc install the same binaries."

  def install
    # avoid adding the SDK library directory to the linker search path
    ENV["XML2_CONFIG"] = "xml2-config --exec-prefix=/usr"

    ENV.prepend "LDFLAGS", "-L#{Formula["openssl"].opt_lib} -L#{Formula["readline"].opt_lib}"
    ENV.prepend "CPPFLAGS", "-I#{Formula["openssl"].opt_include} -I#{Formula["readline"].opt_include}"

    args = %W[
      --disable-debug
      --prefix=#{prefix}
      --datadir=#{HOMEBREW_PREFIX}/share/postgresql
      --libdir=#{HOMEBREW_PREFIX}/lib
      --sysconfdir=#{etc}
      --docdir=#{doc}
      --enable-thread-safety
      --with-icu
      --with-libxml
      --with-libxslt
      --with-openssl
      --with-perl
      --with-uuid=e2fs
    ]
    if OS.mac?
      args += %w[
        --with-bonjour
        --with-gssapi
        --with-ldap
        --with-pam
      ]
    end

    # The CLT is required to build Tcl support on 10.7 and 10.8 because
    # tclConfig.sh is not part of the SDK
    if OS.mac?
      args << "--with-tcl"
      if File.exist?("#{MacOS.sdk_path}/System/Library/Frameworks/Tcl.framework/tclConfig.sh")
        args << "--with-tclconfig=#{MacOS.sdk_path}/System/Library/Frameworks/Tcl.framework"
      end
    end

    system "./configure", *args
    system "make"
    system "make", "install-world", "datadir=#{pkgshare}",
                                    "libdir=#{lib}",
                                    "pkglibdir=#{lib}/postgresql"
  end

  def post_install
    (var/"log").mkpath
    (var/"postgres").mkpath
    if !Process.euid.zero? && !(File.exist? "#{var}/#{name}/PG_VERSION")
      system "#{bin}/initdb", "--locale=C", "-E", "UTF-8", "#{var}/postgres"
    end
  end

  def caveats; <<~EOS
    To migrate existing data from a previous major version of PostgreSQL run:
      brew postgresql-upgrade-database
  EOS
  end

  plist_options :manual => "pg_ctl -D #{HOMEBREW_PREFIX}/var/postgres start"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>KeepAlive</key>
      <true/>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/postgres</string>
        <string>-D</string>
        <string>#{var}/postgres</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardOutPath</key>
      <string>#{var}/log/postgres.log</string>
      <key>StandardErrorPath</key>
      <string>#{var}/log/postgres.log</string>
    </dict>
    </plist>
  EOS
  end

  test do
    system "#{bin}/initdb", testpath/"test"
    assert_equal "#{HOMEBREW_PREFIX}/share/postgresql", shell_output("#{bin}/pg_config --sharedir").chomp
    assert_equal "#{HOMEBREW_PREFIX}/lib", shell_output("#{bin}/pg_config --libdir").chomp
    assert_equal "#{HOMEBREW_PREFIX}/lib/postgresql", shell_output("#{bin}/pg_config --pkglibdir").chomp
  end
end
