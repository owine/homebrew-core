class FernApi < Formula
  desc "Stripe-level SDKs and Docs for your API"
  homepage "https://buildwithfern.com/"
  url "https://registry.npmjs.org/fern-api/-/fern-api-3.4.0.tgz"
  sha256 "78642a5a9aafc41493ed0c129d56824f25b52927acfcb75c548e18c6924fe9e2"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any,                 arm64_tahoe:   "dde5c346279bb7a501b58fdf0692fbbd8c713abb39cff664f0d1ef2a20c7ee2d"
    sha256 cellar: :any,                 arm64_sequoia: "451ad8bbf7a4eb349d2e01f486c9beb656f022f916506fd8c944831e99dcb513"
    sha256 cellar: :any,                 arm64_sonoma:  "451ad8bbf7a4eb349d2e01f486c9beb656f022f916506fd8c944831e99dcb513"
    sha256 cellar: :any,                 sonoma:        "7daf4106b3434895000f6f4ec617fb07a2f4146dd47919d796668227e2a758b3"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "a2cd03b506c31f0995749325bf03d802c3c32e6aa219aa5cfb9678151f0c2b6e"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "d862ca191e9dae34a90c0b1d2c275f386d19e30ca3ff1e210339192f19104877"
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
