class Clarinet < Formula
  desc "Command-line tool and runtime for the Clarity smart contract language"
  homepage "https://www.hiro.so/clarinet"
  url "https://github.com/hirosystems/clarinet/archive/refs/tags/v3.9.0.tar.gz"
  sha256 "2b89f7ddbcda1c57a2e4349538d6a7db29009ea816e0cae71303bd68a3c3e566"
  license "GPL-3.0-only"
  head "https://github.com/hirosystems/clarinet.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "87ec5f44629ee7502ef0fb5622bea4ae4e570349536566d08d23fc61afb06bb2"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "c0b2d16fdbd3b11a707228d2c88222f1a82ee4f7281b795f30a863151e309288"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "b96eab3d7716f86014183785fb971798bb8e7fd054bd73f94a3c7992333b9fba"
    sha256 cellar: :any_skip_relocation, sonoma:        "77a81b3e859c3c82c13eb061c1e569f579c4fa431359f61db8d41993784fb1e8"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "0eb38fe0073e6b4d97e0d1ebc42cd8c96760eb45b9065e4b1f1a9adf5aceb6f1"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "99d55adfcfc36f58c2e08ec23a24f7db76f42bf0b5a986d6650715bc764f8f94"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: "components/clarinet-cli")
  end

  test do
    pipe_output("#{bin}/clarinet new test-project", "n\n")
    assert_match "name = \"test-project\"", (testpath/"test-project/Clarinet.toml").read
    system bin/"clarinet", "check", "--manifest-path", "test-project/Clarinet.toml"
  end
end
