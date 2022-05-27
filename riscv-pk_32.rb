class RiscvPk < Formula
  desc "RISC-V Proxy Kernel"
  homepage "http://riscv.org"
  url "https://github.com/riscv/riscv-pk.git"
  version "main"

  bottle do
    root_url "http://riscv.org.s3.amazonaws.com/bottles"
    rebuild 8
    sha256 cellar: :any_skip_relocation, monterey: "3866b71a6d97a9cb63d29c589cf7177fcecc01f657accdf2e5604b4a1394ca9c"
  end
  option "with-NOmultilib", "Build WITHOUT multilib support"
  depends_on "gnu-sed" => :build
  depends_on "riscv-gnu-toolchain" => :build
  depends_on "riscv-isa-sim" => :build

  def install
  system "wget https://img.victoryang00.cn/riscv-pk_32.zip"
  system "unzip riscv-pk_32.zip -d #{prefix}"
  test do
    system "false"
  end
end
