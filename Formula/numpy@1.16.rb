class NumpyAT116 < Formula
  desc "Package for scientific computing with Python"
  homepage "https://www.numpy.org/"
  url "https://github.com/numpy/numpy/releases/download/v1.16.6/numpy-1.16.6.zip"
  sha256 "e5cf3fdf13401885e8eea8170624ec96225e2174eb0c611c6f26dd33b489e3ff"
  license "BSD-3-Clause"
  revision 1

  bottle do
    rebuild 1
    sha256 cellar: :any, arm64_monterey: "44632bb6f64ba1e0c69135cedb6492366d1bb694db485e98d5ad9154c2de7fe1"
    sha256 cellar: :any, arm64_big_sur:  "7642b59316ab6f72a98404891e507f30ace7fa4155b51f0bee34bd0420616b7b"
    sha256 cellar: :any, monterey:       "d6bb3264733e935d0d0de1d88169424cf4135bc93ff3f634a5878054531f035f"
    sha256 cellar: :any, big_sur:        "06715ef4325d085e529164cc2818e5cf21acb4ef38014a36f93a13adcdbf66c8"
    sha256 cellar: :any, catalina:       "e394780485048f7e2629b168da0a01d0ad55d17200f69749a33e7ac1059f7aac"
  end

  # was used only by opencv@2 which was deprecated on the same date
  # also uses Python 2 which is not supported anymore
  deprecate! date: "2015-02-01", because: :unsupported

  depends_on "gcc" => :build # for gfortran
  depends_on :macos # Due to Python 2
  depends_on "openblas"

  resource "Cython" do
    url "https://files.pythonhosted.org/packages/d9/82/d01e767abb9c4a5c07a6a1e6f4d5a8dfce7369318d31f48a52374094372e/Cython-0.29.15.tar.gz"
    sha256 "60d859e1efa5cc80436d58aecd3718ff2e74b987db0518376046adedba97ac30"
  end

  resource "nose" do
    url "https://files.pythonhosted.org/packages/58/a5/0dc93c3ec33f4e281849523a5a913fa1eea9a3068acfa754d44d88107a44/nose-1.3.7.tar.gz"
    sha256 "f1bffef9cbc82628f6e7d7b40d7e255aefaa1adb6a1b1d26c69a8b79e6208a98"
  end

  def install
    openblas = Formula["openblas"].opt_prefix
    ENV["ATLAS"] = "None" # avoid linking against Accelerate.framework
    ENV["BLAS"] = ENV["LAPACK"] = "#{openblas}/lib/libopenblas.dylib"

    config = <<~EOS
      [openblas]
      libraries = openblas
      library_dirs = #{openblas}/lib
      include_dirs = #{openblas}/include
    EOS

    Pathname("site.cfg").write config

    version = Language::Python.major_minor_version "python"
    dest_path = lib/"python#{version}/site-packages"
    dest_path.mkpath

    nose_path = libexec/"nose/lib/python#{version}/site-packages"
    resource("nose").stage do
      system "python", *Language::Python.setup_install_args(libexec/"nose")
      (dest_path/"homebrew-numpy-nose.pth").write "#{nose_path}\n"
    end

    ENV.prepend_create_path "PYTHONPATH", buildpath/"tools/lib/python#{version}/site-packages"
    resource("Cython").stage do
      system "python", *Language::Python.setup_install_args(buildpath/"tools")
    end

    system "python", "setup.py",
      "build", "--fcompiler=gnu95", "--parallel=#{ENV.make_jobs}",
      "install", "--prefix=#{prefix}",
      "--single-version-externally-managed", "--record=installed.txt"

    rm_f bin/"f2py" # avoid conflict with numpy
  end

  test do
    system "python", "-c", <<~EOS
      import numpy as np
      t = np.ones((3,3), int)
      assert t.sum() == 9
      assert np.dot(t, t).sum() == 27
    EOS
  end
end
