class GeminiCli < Formula
  desc "Interact with Google Gemini AI models from the command-line"
  homepage "https://github.com/google-gemini/gemini-cli"
  url "https://registry.npmjs.org/@google/gemini-cli/-/gemini-cli-0.15.0.tgz"
  sha256 "72332fbb0160a4ef82db11bcd9de9a5e63445af4f134d2e498a45512c6eb4459"
  license "Apache-2.0"

  bottle do
    sha256                               arm64_tahoe:   "a843d6ff4420c0259fafa331534031f9ad28baf57f8456152b03ab081a43bc80"
    sha256                               arm64_sequoia: "ce6bcd5002038327a7fc801a644861db64c67fe78be1160de03a9ca436546c82"
    sha256                               arm64_sonoma:  "8a4b66990cf6417be391952183216e689e7eb7c32319e74af475b0972916fd9e"
    sha256                               sonoma:        "d3cc96ccf74ff59d32981ab530fd0df9c7f176638288b047cc8a3524ea135533"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "38c20f0d8934b0616fdee3441db20e0c16e91f05110aba0d3aeba2faf49899d7"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "419cd6c309f8a6a7298a060204ea201522b23f36fb91da0fa5f2b458ec7d1948"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]

    # Remove incompatible pre-built binaries
    os = OS.kernel_name.downcase
    arch = Hardware::CPU.intel? ? "x64" : Hardware::CPU.arch.to_s
    node_modules = libexec/"lib/node_modules/@google/gemini-cli/node_modules"
    libexec.glob("#{node_modules}/tree-sitter-bash/prebuilds/*")
           .each { |dir| rm_r(dir) if dir.basename.to_s != "#{os}-#{arch}" }
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/gemini --version")

    assert_match "Please set an Auth method", shell_output("#{bin}/gemini --prompt Homebrew 2>&1", 1)
  end
end
