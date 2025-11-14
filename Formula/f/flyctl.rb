class Flyctl < Formula
  desc "Command-line tools for fly.io services"
  homepage "https://fly.io"
  url "https://github.com/superfly/flyctl.git",
      tag:      "v0.3.213",
      revision: "4cb2b03eb95d0df48f1a966107852dd2811fd35f"
  license "Apache-2.0"
  head "https://github.com/superfly/flyctl.git", branch: "master"

  # Upstream tags versions like `v0.1.92` and `v2023.9.8` but, as of writing,
  # they only create releases for the former and those are the versions we use
  # in this formula. We could omit the date-based versions using a regex but
  # this uses the `GithubLatest` strategy, as the upstream repository also
  # contains over a thousand tags (and growing).
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "644624dd657308adc7082ca2e87551bccf4cf3f123c76c03cacd6074e2657d24"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "644624dd657308adc7082ca2e87551bccf4cf3f123c76c03cacd6074e2657d24"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "644624dd657308adc7082ca2e87551bccf4cf3f123c76c03cacd6074e2657d24"
    sha256 cellar: :any_skip_relocation, sonoma:        "dda2f9aa9277aa6a0233d6c0ac5c5ee54042b02ed631a4a1ff9d512b6d3c408c"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "97b1b949b31da41fc40eb422214e54c5651b5038f3c2a1da827d46355c31a404"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "94b94671f9407dd7a211222ca46fc9f922402a06560191f893a010baa4232d5c"
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    ldflags = %W[
      -s -w
      -X github.com/superfly/flyctl/internal/buildinfo.buildDate=#{time.iso8601}
      -X github.com/superfly/flyctl/internal/buildinfo.buildVersion=#{version}
      -X github.com/superfly/flyctl/internal/buildinfo.commit=#{Utils.git_short_head}
    ]
    system "go", "build", *std_go_args(ldflags:, tags: "production")

    bin.install_symlink "flyctl" => "fly"

    generate_completions_from_executable(bin/"flyctl", "completion")
    generate_completions_from_executable(bin/"fly", "completion")
  end

  test do
    assert_match "flyctl v#{version}", shell_output("#{bin}/flyctl version")

    flyctl_status = shell_output("#{bin}/flyctl status 2>&1", 1)
    assert_match "Error: No access token available. Please login with 'flyctl auth login'", flyctl_status

    json = <<~JSON
      {"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26"}}
      {"jsonrpc":"2.0","id":2,"method":"tools/list"}
    JSON

    assert_match "Create a new Fly.io app", pipe_output("#{bin}/flyctl mcp server", json, 0)
  end
end
