class Qcachegrind < Formula
  desc "Visualize data generated by Cachegrind and Calltree"
  homepage "https://kcachegrind.github.io/"
  url "https://download.kde.org/stable/release-service/23.08.4/src/kcachegrind-23.08.4.tar.xz"
  sha256 "7cf17ae3b87c2b4c575f2eceddae84b412f5f6dfcee8a0f15755e6eed3d22b04"
  license "GPL-2.0-or-later"

  # We don't match versions like 19.07.80 or 19.07.90 where the patch number
  # is 80+ (beta) or 90+ (RC), as these aren't stable releases.
  livecheck do
    url "https://download.kde.org/stable/release-service/"
    regex(%r{href=.*?v?(\d+\.\d+\.(?:(?![89]\d)\d+)(?:\.\d+)*)/?["' >]}i)
  end

  bottle do
    sha256 cellar: :any,                 arm64_sonoma:   "af56745981b9bc4b9a5cacdbdf479277bed914c06277da3f475bbdbf9454230b"
    sha256 cellar: :any,                 arm64_ventura:  "fb2b900356e44197bcd43b576b14ed1281afc8007ab2b6dbb532ef61ed387ce6"
    sha256 cellar: :any,                 arm64_monterey: "efee8887ae3ba14e598ccde430760c48a94209ef7318fabea86bb1b8238cbfcb"
    sha256 cellar: :any,                 sonoma:         "983d2aad0e681457bac3532308f87121b4370f431ba554c1c8bc5b82b79eb381"
    sha256 cellar: :any,                 ventura:        "cac5c9e47a4f9d503ec27d16b3cdc8b11d0fa2e17b0333a93da9bbd15a232cce"
    sha256 cellar: :any,                 monterey:       "aa9c7c1b7b15c77af75072d7f692a002a7511cb68ddd8d5704f94cccfa2996a9"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "1a71f38f9fe82c6830aa0c418e7736c17255049b375d5fdfbb283d262e7edc16"
  end

  depends_on "graphviz"
  depends_on "qt@5"

  fails_with gcc: "5"

  def install
    args = []
    if OS.mac?
      # TODO: when using qt 6, modify the spec
      spec = (ENV.compiler == :clang) ? "macx-clang" : "macx-g++"
      args = %W[-config release -spec #{spec}]
    end

    system Formula["qt@5"].opt_bin/"qmake", *args
    system "make"

    if OS.mac?
      prefix.install "qcachegrind/qcachegrind.app"
      bin.install_symlink prefix/"qcachegrind.app/Contents/MacOS/qcachegrind"
    else
      bin.install "qcachegrind/qcachegrind"
    end
  end
end
