# terraform: Build a bottle for Linuxbrew
require "language/go"

class Terraform < Formula
  desc "Tool to build, change, and version infrastructure"
  homepage "https://www.terraform.io/"
  url "https://github.com/hashicorp/terraform/archive/v0.9.8.tar.gz"
  sha256 "df2bf4710360778dec1b3ebe1e60e692fe4ff1474947ecb05903d2cc62e5d6ad"
  head "https://github.com/hashicorp/terraform.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "768fa90a7864302855e67551150c46fcf93fe68ed347a8e819032f58824fe342" => :sierra
    sha256 "dd5cc1af0deda44c5656e3ac429959e253805b6ad9157085c1380f790ec3a3d3" => :el_capitan
    sha256 "f34bc477fe83d4b5878bbc60edbcc08e001f945c82fbf7c2c813362b801e22e4" => :yosemite
  end

  depends_on "go" => :build

  conflicts_with "tfenv", :because => "tfenv symlinks terraform binaries"

  go_resource "github.com/mitchellh/gox" do
    url "https://github.com/mitchellh/gox.git",
        :revision => "c9740af9c6574448fd48eb30a71f964014c7a837"
  end

  go_resource "github.com/mitchellh/iochan" do
    url "https://github.com/mitchellh/iochan.git",
        :revision => "87b45ffd0e9581375c491fef3d32130bb15c5bd7"
  end

  go_resource "github.com/kisielk/errcheck" do
    url "https://github.com/kisielk/errcheck.git",
        :revision => "23699b7e2cbfdb89481023524954ba2aeff6be90"
  end

  go_resource "github.com/kisielk/gotool" do
    url "https://github.com/kisielk/gotool.git",
        :revision => "0de1eaf82fa3f583ce21fde859f1e7e0c5e9b220"
  end

  go_resource "golang.org/x/tools" do
    url "https://go.googlesource.com/tools.git",
        :revision => "5682db0e919ed9cfc6f52ac32e170511a106eb3b"
  end

  def install
    ENV["GOPATH"] = buildpath
    ENV.prepend_create_path "PATH", buildpath/"bin"

    dir = buildpath/"src/github.com/hashicorp/terraform"
    dir.install buildpath.children - [buildpath/".brew_home"]
    Language::Go.stage_deps resources, buildpath/"src"

    %w[src/github.com/mitchellh/gox src/golang.org/x/tools/cmd/stringer
       src/github.com/kisielk/errcheck].each do |path|
      cd(path) { system "go", "install" }
    end

    cd dir do
      # v0.6.12 - source contains tests which fail if these environment variables are set locally.
      ENV.delete "AWS_ACCESS_KEY"
      ENV.delete "AWS_SECRET_KEY"

      arch = MacOS.prefer_64_bit? ? "amd64" : "386"
      ENV["XC_OS"] = OS::NAME
      ENV["XC_ARCH"] = arch
      system "make", "test", "vet", "bin"

      bin.install "pkg/#{OS::NAME}_#{arch}/terraform"
      zsh_completion.install "contrib/zsh-completion/_terraform"
      prefix.install_metafiles
    end
  end

  test do
    minimal = testpath/"minimal.tf"
    minimal.write <<-EOS.undent
      variable "aws_region" {
          default = "us-west-2"
      }

      variable "aws_amis" {
          default = {
              eu-west-1 = "ami-b1cf19c6"
              us-east-1 = "ami-de7ab6b6"
              us-west-1 = "ami-3f75767a"
              us-west-2 = "ami-21f78e11"
          }
      }

      # Specify the provider and access details
      provider "aws" {
          access_key = "this_is_a_fake_access"
          secret_key = "this_is_a_fake_secret"
          region = "${var.aws_region}"
      }

      resource "aws_instance" "web" {
        instance_type = "m1.small"
        ami = "${lookup(var.aws_amis, var.aws_region)}"
        count = 4
      }
    EOS
    system "#{bin}/terraform", "graph", testpath
  end
end
