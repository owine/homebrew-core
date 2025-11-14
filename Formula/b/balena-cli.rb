class BalenaCli < Formula
  desc "Command-line tool for interacting with the balenaCloud and balena API"
  homepage "https://docs.balena.io/reference/balena-cli/latest/"
  url "https://registry.npmjs.org/balena-cli/-/balena-cli-22.5.3.tgz"
  sha256 "a8f6741f84427ebe9bbdf0362cde8db14e80098742fb0acdc55dc331ce065e5d"
  license "Apache-2.0"

  livecheck do
    url "https://registry.npmjs.org/balena-cli/latest"
    strategy :json do |json|
      json["version"]
    end
  end

  bottle do
    sha256                               arm64_tahoe:   "53ac78deafe584d22737a399e2502eaca7e8f7b245269aaf44208e1714bb2f9a"
    sha256                               arm64_sequoia: "70efb433a9b0056b95cc141ea0b98573a086263e3bbd958a5f2232b742ae8559"
    sha256                               arm64_sonoma:  "887d78d500034647be943ce953e728d42650bf99101a9def53d7a07515541f63"
    sha256                               sonoma:        "ff742a71bf70e039ee6c03d1beccdcf853a7651c68061022e1c3234d8dc2ac37"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "11060743e1861566e8a6b4b2ecce492402b696f511e04d9e9f5c746cde0c681b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "752dd925dc81155ac240eb94bdd2957af2614ca29f85e6dbc7416e8ef31ce284"
  end

  # align with upstream, https://github.com/balena-io/balena-cli/blob/master/.github/actions/publish/action.yml#L21
  depends_on "node@22"

  on_linux do
    depends_on "libusb"
    depends_on "systemd" # for libudev
    depends_on "xz" # for liblzma
  end

  def install
    ENV.deparallelize

    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")

    # Remove incompatible pre-built binaries
    os = OS.kernel_name.downcase
    arch = Hardware::CPU.intel? ? "x64" : Hardware::CPU.arch.to_s
    node_modules = libexec/"lib/node_modules/balena-cli/node_modules"
    node_modules.glob("{bcrypt,lzma-native,mountutils}/prebuilds/*")
                .each do |dir|
                  if dir.basename.to_s == "#{os}-#{arch}"
                    dir.glob("*.musl.node").each(&:unlink) if OS.linux?
                  else
                    rm_r(dir)
                  end
                end

    rm_r(node_modules/"lzma-native/build")
    rm_r(node_modules/"usb") if OS.linux?

    # Replace universal binaries with native slices
    deuniversalize_machos
  end

  test do
    assert_match "Logging in to balena-cloud.com",
      shell_output("#{bin}/balena login --credentials --email johndoe@gmail.com --password secret 2>/dev/null", 1)
  end
end
