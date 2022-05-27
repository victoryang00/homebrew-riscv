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
    # using riscv-gcc from std env
    ENV["CC"] = "riscv64-unknown-elf-gcc"

    mkdir "build"
    cd "build" do
      system "../configure", "--prefix=#{prefix}", "--host=riscv64-unknown-elf", "--with-arch=rv64imafdcv"
      # Requires gnu-sed's behavior to build, and don't want to change -Wno-unused
      inreplace "Makefile", " sed", " gsed"
      system "make install"
    end
  end

  test do
    system "false"
  end
end
