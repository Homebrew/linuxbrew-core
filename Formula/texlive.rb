class Texlive < Formula
  desc "Free software distribution for the TeX typesetting system"
  homepage "https://www.tug.org/texlive/"
  url "https://www.texlive.info/tlnet-archive/2021/04/15/tlnet/install-tl-unx.tar.gz"
  version "20210415"
  sha256 "eae3c20c7d543e27f72370caef35d2026b413c90cf3ba6e9d942d32325e534c7"
  head "http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz"

  depends_on "wget" => :build
  depends_on "fontconfig"
  depends_on "libice"
  depends_on "libsm"
  depends_on "libx11"
  depends_on "libxaw"
  depends_on "libxext"
  depends_on "libxmu"
  depends_on "libxpm"
  depends_on "libxt"
  depends_on :linux
  depends_on "perl"

  def install
    ohai "Downloading and installing TeX Live. This will take a few minutes."

    ENV["TEXLIVE_INSTALL_PREFIX"] = prefix

    File.write("texlive.profile", <<-END
      selected_scheme scheme-small
      TEXDIR #{prefix}/texlive
      TEXMFCONFIG $TEXMFSYSCONFIG
      TEXMFHOME $TEXMFLOCAL
      TEXMFLOCAL #{prefix}/texlive/texmf-local
      TEXMFSYSCONFIG #{prefix}/texlive/texmf-config
      TEXMFSYSVAR #{prefix}/texlive/texmf-var
      TEXMFVAR $TEXMFSYSVAR
      instopt_adjustpath 1
      instopt_adjustrepo 1
      instopt_letter 0
      instopt_portable 0
      instopt_write18_restricted 1
      tlpdbopt_autobackup 1
      tlpdbopt_backupdir tlpkg/backups
      tlpdbopt_create_formats 1
      tlpdbopt_desktop_integration 1
      tlpdbopt_file_assocs 1
      tlpdbopt_generate_updmap 0
      tlpdbopt_install_docfiles 1
      tlpdbopt_install_srcfiles 1
      tlpdbopt_post_code 1
      tlpdbopt_sys_bin #{bin}
      tlpdbopt_sys_info #{info}
      tlpdbopt_sys_man #{man}
      tlpdbopt_w32_multi_user 1
    END
    )

    system "./install-tl", "-profile", "./texlive.profile"
    Pathname.glob(bin/"*") { |f| chmod 0555, f.realpath }

    # add the backup directory otherwise any tlmgr package update will fail
    # complaining that the backup dir does not exist.
    mkdir prefix/"texlive/tlpkg/backups"
    touch prefix/"texlive/tlpkg/backups/.keep"
  end

  def caveats
    <<-EOS
      The small (~500 MB) distribution (scheme-small) by default.

      You may install a larger (medium or full) scheme using one of:

          > tlmgr install scheme-medium # 1.5 GB
          > tlmgr install scheme-full # 6 GB

      After any additional package installation, if you would like to update
      the symlinks do:

          > tlmgr path add
          > brew unlink texlive && brew link texlive

      For additional information on how to manage texlive packages:

          > tlmgr --help

    EOS
  end

  test do
    assert_match "Usage", shell_output("#{bin}/tex --help")
    assert_match "revision", shell_output("#{bin}/tlmgr --version")
  end
end
