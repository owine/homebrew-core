class Enzyme < Formula
  desc "High-performance automatic differentiation of LLVM"
  homepage "https://enzyme.mit.edu"
  url "https://github.com/EnzymeAD/Enzyme/archive/refs/tags/v0.0.215.tar.gz"
  sha256 "a8c9b0fea54aed5dca966b51d47ec3bccebff41b8f9310ad5201d6eac89603f4"
  license "Apache-2.0" => { with: "LLVM-exception" }
  head "https://github.com/EnzymeAD/Enzyme.git", branch: "main"

  bottle do
    sha256 cellar: :any,                 arm64_tahoe:   "e603faffc8d3cf1e7a1e5c481acc23d86e674b076c321f2b6e56c49366ad1329"
    sha256 cellar: :any,                 arm64_sequoia: "5a2bb0bd9647c745dd77fadd8e6e5bce9f533dc23fe5aff341e6259d9c84ab4d"
    sha256 cellar: :any,                 arm64_sonoma:  "4c904c4338742863b48926c2be09ac72e1d5076f2040fbfc8051eecceb839e26"
    sha256 cellar: :any,                 sonoma:        "18c2797b134ceee98e8d33fb94540a67af732752df84c77de4ae2e3bd51c052c"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "c0578a21bf1c41489a2d2eb6679dad9318f75b80b094bd040066f9cfdddb5f48"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "e358610bd47bca6990fc4913e0abf9e36d762243bf7729eb11f2a5254c926be2"
  end

  depends_on "cmake" => :build
  depends_on "llvm"

  def llvm
    deps.map(&:to_formula).find { |f| f.name.match?(/^llvm(@\d+)?$/) }
  end

  def install
    system "cmake", "-S", "enzyme", "-B", "build", "-DLLVM_DIR=#{llvm.opt_lib}/cmake/llvm", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include <stdio.h>
      extern double __enzyme_autodiff(void*, double);
      double square(double x) {
        return x * x;
      }
      double dsquare(double x) {
        return __enzyme_autodiff(square, x);
      }
      int main() {
        double i = 21.0;
        printf("square(%.0f)=%.0f, dsquare(%.0f)=%.0f\\n", i, square(i), i, dsquare(i));
      }
    C

    ENV["CC"] = llvm.opt_bin/"clang"

    system ENV.cc, testpath/"test.c",
                        "-fplugin=#{lib/shared_library("ClangEnzyme-#{llvm.version.major}")}",
                        "-O1", "-o", "test"

    assert_equal "square(21)=441, dsquare(21)=42\n", shell_output("./test")
  end
end
