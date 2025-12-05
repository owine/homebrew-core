class Cagent < Formula
  desc "Agent Builder and Runtime by Docker Engineering"
  homepage "https://github.com/docker/cagent"
  url "https://github.com/docker/cagent/archive/refs/tags/v1.10.5.tar.gz"
  sha256 "8bd543c6f6416390e256acacb5841fce9136b3499db784520bec27bccfccd149"
  license "Apache-2.0"
  head "https://github.com/docker/cagent.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "c41f7aaa580222482a1b37ba7f19f99b2634ef3c856b057382af3591f4995737"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "bb7d521d157b0c180ca4e69721ec3820ce454e612279e48738d0a2221630f9f8"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "fc7f465811bfa7a7ccbe786ed5bdd4b2ec6bfb41d4524eb058137417ad79d1ce"
    sha256 cellar: :any_skip_relocation, sonoma:        "8ff5c832dfe1a5f2902b581bf07b1f3589ec9d1c113e9c631a2691c1cc269f1f"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "21b62ff401b284f2e4a0bc8c44d1d9c5f30c49de593c3b75953843b531df834f"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "a065145152d5002c3294792ce5f3a6e042eafd20f48cf7525ea4e68d29defa53"
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "1" if OS.linux? && Hardware::CPU.arm?

    ldflags = %W[
      -s -w
      -X github.com/docker/cagent/pkg/version.Version=v#{version}
      -X github.com/docker/cagent/pkg/version.Commit=#{tap.user}
    ]

    system "go", "build", *std_go_args(ldflags:)

    generate_completions_from_executable(bin/"cagent", "completion")
  end

  test do
    (testpath/"agent.yaml").write <<~YAML
      version: "2"
      agents:
        root:
          model: openai/gpt-4o
    YAML

    assert_match("cagent version v#{version}", shell_output("#{bin}/cagent version"))
    assert_match(/must be set.*OPENAI_API_KEY/m, shell_output("#{bin}/cagent exec --dry-run agent.yaml 2>&1", 1))
  end
end
