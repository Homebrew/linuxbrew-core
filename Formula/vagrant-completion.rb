class VagrantCompletion < Formula
  desc "Bash completion for Vagrant"
  homepage "https://github.com/hashicorp/vagrant"
  url "https://github.com/hashicorp/vagrant/archive/v2.2.17.tar.gz"
  sha256 "4f8f2e8bb8e0abd9e2de90b4f497765b3913f4f05a27e4940df71703940c8ccf"
  license "MIT"
  head "https://github.com/hashicorp/vagrant.git", branch: "main"

  def install
    bash_completion.install "contrib/bash/completion.sh" => "vagrant"
    zsh_completion.install "contrib/zsh/_vagrant"
  end

  test do
    assert_match "-F _vagrant",
      shell_output("source #{bash_completion}/vagrant && complete -p vagrant")
  end
end
