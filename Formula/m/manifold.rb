class Manifold < Formula
  desc "Geometry library for topological robustness"
  homepage "https://github.com/elalish/manifold"
  url "https://github.com/elalish/manifold/releases/download/v3.3.0/manifold-3.3.0.tar.gz"
  sha256 "af0ea17e5006c71b439371570ccc143cd5fbd77a18c4fa713a508ef1fc3e2845"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any,                 arm64_tahoe:   "5227a815585053204ee1b1abef077bf288f03a4cc893e4bf468b9044d6c11024"
    sha256 cellar: :any,                 arm64_sequoia: "5b74e3ea9344c69db2f5176b1c9f08d9b978001dea42fd13cddf8c647e6ef82d"
    sha256 cellar: :any,                 arm64_sonoma:  "82336a4cd514fd3a4db7a367a9c59f3b2145959348197093a0d52b8370386650"
    sha256 cellar: :any,                 sonoma:        "ae5579a7cc4a5c318aa02e2355dea010e83d06ae33ccd0dc763b056d971e84a3"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "05c5ba643c345e243930c62a694de1d733306bb356e83a368f0105f072aeb3d6"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "3445c2c7a4f5a3064e304b534055a6729eb7376ae44b64a3f65841d1d74bcb7d"
  end

  depends_on "cmake" => :build
  depends_on "clipper2"
  depends_on "tbb"

  def install
    args = %w[
      -DMANIFOLD_DOWNLOADS=OFF
      -DMANIFOLD_PAR=ON
      -DMANIFOLD_TEST=OFF
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    pkgshare.install "extras/large_scene_test.cpp"
  end

  test do
    system ENV.cxx, pkgshare/"large_scene_test.cpp",
                    "-std=c++17", "-I#{include}", "-L#{lib}", "-lmanifold",
                    "-o", "test"
    assert_match "nTri = 91814", shell_output("./test")
  end
end
