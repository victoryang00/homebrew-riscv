class RiscvRvvLlvm < Formula
    desc "RISC-V LLVM Compiler with RVV support"
    homepage "http://llvm.org"
    url "https://github.com/llvm/llvm-project.git"
    version "llvmorg-15-init"

    option "with-NOVExt", "Build WITHOUT V Extension"
    option "with-NOmultilib", "Build WITHOUT multilib support"

    depends_on "cmake" => :build
    
    def install
        # disable crazy flag additions
        ENV.delete "CPATH"
    
        args = [
          "--prefix=#{prefix}"
        ]
        args << "--enable-multilib" unless build.with?("NOmultilib")
        args << "--disable-multilib" if build.with?("NOmultilib")

        system "export ARCH64=rv64gc; export CLANG_ARCH64=${ARCH64};export ABI64=lp64d; export TARGET64=riscv64-unknown-elf; export CLANG_CFLAGS64='--target=${TARGET64} -march=${CLANG_ARCH64} -mabi=${ABI64}'" if build.with?("NOVExt")
    
        system "export ARCH64=rv64gcv; export CLANG_ARCH64='${ARCH64}0p10 -menable-experimental-extensions';export ABI64=lp64d; export TARGET64=riscv64-unknown-elf; export CLANG_CFLAGS64='--target=${TARGET64} -march=${CLANG_ARCH64} -mabi=${ABI64}'" unless build.with?("NOVExt")
        
        # Build clang first
        system "mkdir build_clang && cd build_clang && cmake -DLLVM_ENABLE_PROJECTS='clang;lld' -G'Unix Makefiles' ../llvm -GCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=#{prefix} -DLLVM_TARGETS_TO_BUILD='RISCV' -DLLVM_DEFAULT_TARGET_TRIPLE=$TARGET64 -DLLVM_BUILD_EXAMPLES=OFF -DLLVM_INCLUDE_EXAMPLES=OFF -DBUILD_SHARED_LIBS=OFF -DLLVM_OPTIMIZED_TABLEGEN=ON -DLLVM_ENABLE_LIBXML2=OFF -DCLANG_DEFAULT_RTLIB=compiler-rt -DCLANG_DEFAULT_UNWINDLIB=libunwind -DCLANG_DEFAULT_CXX_STDLIB=libc++ && make -j4 && make install"

        # Preparation for newlib
        system "export ARGSTR='\"$@\"'; echo '#{prefix}/bin/clang ${CLANG_CFLAGS64} -Wno-unused-command-line-argument ${ARGSTR}' > #{prefix}/bin/riscv64-unknown-elf-clang && chmod +x #{prefix}/bin/riscv64-unknown-elf-clang"
        system "export ARGSTR='\"$@\"'; echo '#{prefix}/bin/clang++ ${CLANG_CFLAGS64} -Wno-unused-command-line-argument ${ARGSTR}' > #{prefix}/bin/riscv64-unknown-elf-clang++ && chmod +x #{prefix}/bin/riscv64-unknown-elf-clang++"
        system "export PATH=#{prefix}/bin/:$PATH; export CFLAGS_FOR_TARGET=' -g -gdwarf-3 -gstrict-dwarf -O2 -ffunction-sections -fdata-sections '; export CC_FOR_TARGET=$TARGET64-clang; export AS_FOR_TARGET=$TARGET64-clang;export LD_FOR_TARGET=lld;export CXX_FOR_TARGET=$TARGET64-clang++; export AR_FOR_TARGET=llvm-ar; export NM_FOR_TARGET=llvm-nm; export RANLIB_FOR_TARGET=llvm-ranlib; export OBJCOPY_FOR_TARGET=llvm-objcopy; export OBJDUMP_FOR_TARGET=llvm-objdump; export READELF_FOR_TARGET=llvm-readelf; export STRIP_FOR_TARGET=llvm-strip; export LIPO_FOR_TARGET=llvm-lipo; export DLLTOOL_FOR_TARGET=llvm-dlltool"

        # Build newlib then
        system "cd ../ && wget ftp://sourceware.org/pub/newlib/newlib-4.1.0.tar.gz && tar xvf newlib-4.1.0.tar.gz"
        
        system "cd newlib-4.1.0 && ./configure --target=$TARGET64 --disable-nls", *args
        system "make -j4 && make install"
        
        # Preparation for compiler-rt
        system "export CC='#{prefix}/bin/${TARGET64}-clang'; export CXX='#{prefix}/bin/${TARGET64}-clang++'; export AR='#{prefix}/bin/llvm-ar'; export NM='#{prefix}/bin/llvm-nm'; export RANLIB='#{prefix}/bin/llvm-ranlib'; export OBJCOPY='#{prefix}/bin/llvm-objcopy'; export LLVM_CONFIG='#{prefix}/bin/llvm-config'; TARGET_CFLAGS=''; TARGET_CXXFLAGS='${TARGET_CFLAGS}'; TARGET_LDFLAGS=''; LLVM_VERSION=`$CC -dumpversion`; LLVM_RESOURCEDIR=/lib/clang/$LLVM_VERSION"

        # Build compiler-rt
        system "cd .. && mkdir build_compiler-rt && cd build_compiler-rt && cmake -G 'Unix Makefiles' ../compiler-rt -DCMAKE_INSTALL_PREFIX=#{prefix}/$LLVM_RESOURCEDIR/ -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY -DCMAKE_CROSSCOMPILING=True -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_BUILD_TYPE=Release -DCOMPILER_RT_BUILD_BUILTINS=ON -DCOMPILER_RT_BUILD_SANITIZERS=OFF -DCOMPILER_RT_BUILD_XRAY=OFF -DCOMPILER_RT_BUILD_LIBFUZZER=OFF -DCOMPILER_RT_BUILD_PROFILE=OFF -DCOMPILER_RT_BUILD_MEMPROF=OFF -DCOMPILER_RT_BUILD_XRAY_NO_PREINIT=OFF -DCOMPILER_RT_SANITIZERS_TO_BUILD=none -DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX -DCMAKE_AR=$AR -DCMAKE_NM=$NM -DCMAKE_RANLIB=$RANLIB -DLLVM_CONFIG_PATH=$LLVM_CONFIG -DCMAKE_C_COMPILER_TARGET=$TARGET64 -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON -DCMAKE_C_FLAGS='${TARGET_CFLAGS}' -DCMAKE_CXX_FLAGS='${TARGET_CXXFLAGS}' -DCMAKE_EXE_LINKER_FLAGS='${TARGET_LDFLAGS}' -DCOMPILER_RT_BAREMETAL_BUILD=ON -DCOMPILER_RT_OS_DIR='' && make -j4 && make install"
      test do
        system "false"
      end
    end
end
    