class Vtcode < Formula
  desc "CLI Semantic Coding Agent"
  homepage "https://github.com/vinhnx/vtcode"
  url "https://static.crates.io/crates/vtcode/vtcode-0.43.15.crate"
  sha256 "fc8f2389b803011f7d9472ca6d6cfc25c0376c6b531e2fb079cb662f24a37cef"
  license "MIT"
  head "https://github.com/vinhnx/vtcode.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "938c39f59a9ee06b28a493570b3307afeaad50af3b5c514edd40362ef133ec61"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "996033a4495a8331e560878e6da832df1f633c2cb0362bfaeb309a5376b6accb"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "14efc3f733d955eb4b2bfb6f0fa1cd6e097392b26ee4fa3d107ad2dec6fd30e4"
    sha256 cellar: :any_skip_relocation, sonoma:        "de2f8102b2c5505f2285485167a02ab5ae53f181139efd9d852c94246f9fd64d"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "30f071e93997c31f54dc3dc3715eb03c6f43d88f62407fa087e0ef950ae870bf"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "e9f0704ff849e8ae4c22da3f11580e9672037b1d8cbdf66de8761a15d643040e"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  uses_from_macos "zlib"

  on_linux do
    depends_on "openssl@3"
  end

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/vtcode --version")

    output = shell_output("#{bin}/vtcode init 2>&1", 1)
    assert_match "No API key found for OpenAI provider", output
  end
end
