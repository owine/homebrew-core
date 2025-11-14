class VercelCli < Formula
  desc "Command-line interface for Vercel"
  homepage "https://vercel.com/home"
  url "https://registry.npmjs.org/vercel/-/vercel-48.10.0.tgz"
  sha256 "dc7cc266f875b713b2bbec9f8a86aefe848e2fbf1c998157d63009ebdb80b7c6"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any,                 arm64_tahoe:   "095468ab6983e9ad5d83d8a7adaf9026fba6b05e8fd0bba6c149e312ccd6f95f"
    sha256 cellar: :any,                 arm64_sequoia: "0164d66fe32d52b704cf86d04e5d3635e03093cbbc50e3f2041d5c92cb95218f"
    sha256 cellar: :any,                 arm64_sonoma:  "0164d66fe32d52b704cf86d04e5d3635e03093cbbc50e3f2041d5c92cb95218f"
    sha256 cellar: :any,                 sonoma:        "a824d3b528e5305e27ffc3225186b8f99f0074369e3ba9ebfbee7971f8cdace3"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "c564343297063f5b1a4ac0b9675c08004d00ce496d5274c9c09f1085b67555fe"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "fc3fdbbf003e01c4d090f16e44fddeff085e5c0bc30b5fbe5e99ef830e829309"
  end

  depends_on "node"

  def install
    inreplace "dist/index.js", "${await getUpdateCommand()}",
                               "brew upgrade vercel-cli"
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]

    # Remove incompatible deasync modules
    os = OS.kernel_name.downcase
    arch = Hardware::CPU.intel? ? "x64" : Hardware::CPU.arch.to_s
    node_modules = libexec/"lib/node_modules/vercel/node_modules"
    node_modules.glob("deasync/bin/*")
                .each { |dir| rm_r(dir) if dir.basename.to_s != "#{os}-#{arch}" }
  end

  test do
    system bin/"vercel", "init", "jekyll"
    assert_path_exists testpath/"jekyll/_config.yml", "_config.yml must exist"
    assert_path_exists testpath/"jekyll/README.md", "README.md must exist"
  end
end
