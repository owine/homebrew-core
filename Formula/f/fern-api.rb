class FernApi < Formula
  desc "Stripe-level SDKs and Docs for your API"
  homepage "https://buildwithfern.com/"
  url "https://registry.npmjs.org/fern-api/-/fern-api-1.0.3.tgz"
  sha256 "a5b8fa4078d0d5bf94b51ebf0ec3d61a1034bea9c4e2ea8ea1419f789d729dda"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "fcd548263c14dc4bed82017170ef39b2d1e543f8ce4f64262f491bcf9c32eafc"
  end

  depends_on "node"

  def install
    # Supress self update notifications
    inreplace "cli.cjs", "await this.nudgeUpgradeIfAvailable()", "await 0"
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")
  end

  test do
    system bin/"fern", "init", "--docs", "--org", "brewtest"
    assert_path_exists testpath/"fern/docs.yml"
    assert_match '"organization": "brewtest"', (testpath/"fern/fern.config.json").read

    system bin/"fern", "--version"
  end
end
