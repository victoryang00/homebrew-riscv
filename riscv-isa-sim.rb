class RiscvIsaSim < Formula
  desc "RISC-V ISA simulator (spike)"
  homepage "http://riscv.org"
  url "https://github.com/riscv/riscv-isa-sim.git"
  version "main"

  bottle do
    root_url "http://riscv.org.s3.amazonaws.com/bottles"
    rebuild 10
    sha256 monterey: "15a1a4dba1c43cfe128d6f6d6edf5d441ab04b35beab52959812b13c3c437eb5"
  end

  depends_on "dtc"
  depends_on "boost" => :optional

  opoo "Building with clang could fail due to upstream bug: https://github.com/riscv-software-src/riscv-isa-sim/issues/820" if build.with? "boost"

  def install
    mkdir "build"
    cd "build" do
      args = [
        "--prefix=#{prefix}"
      ]
      if build.with?("BExt")
        args << "--with-arch=rv64imafdcb"
      elsif build.with?("ZExt")
        args << "--with-arch=rv64gc_zba_zbb_zbc_zbe_zbf_zbm_zbp_zbr_zbs_zbt"
      elsif build.with?("KExt")
        args << "--with-arch=rv64imafdck"
      elsif build.with?("NOVExt")
        args << "--with-arch=rv64imafdc"
      else
        args << "--with-arch=rv64imafdcv" 
      end
      if build.with?("boost")
        # This seems to be needed at least on macos/arm64
        args << "--with-boost=#{Formula["boost"].prefix}"
      else
        args << "--without-boost"
        args << "--without-boost-asio"
        args << "--without-boost-regex"
      end
      # configure uses --with-target to set TARGET_ARCH but homebrew formulas only provide "with"/"without" options
      system "../configure", *args 
      system "make"
      system "make", "install"
    end
  end

  test do
    system "false"
  end
end
