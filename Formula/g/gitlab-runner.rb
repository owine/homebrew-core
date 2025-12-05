class GitlabRunner < Formula
  desc "Official GitLab CI runner"
  homepage "https://gitlab.com/gitlab-org/gitlab-runner"
  url "https://gitlab.com/gitlab-org/gitlab-runner.git",
      tag:      "v18.6.4",
      revision: "7a8cff11df3d765adb21165622a7254e72112df3"
  license "MIT"
  head "https://gitlab.com/gitlab-org/gitlab-runner.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "fd4fe0891a182bf5227e29a4f7cf4fc60d81b9ee43649370b753d0adff549431"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "fd4fe0891a182bf5227e29a4f7cf4fc60d81b9ee43649370b753d0adff549431"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "fd4fe0891a182bf5227e29a4f7cf4fc60d81b9ee43649370b753d0adff549431"
    sha256 cellar: :any_skip_relocation, sonoma:        "e7c57065ec664ffca64e109f3a7a0983729a332ee8ba5daf617e46a1f6397a0c"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "ad668a7b0dd463e24856df1095b145a5710c40c257555fb910da1829d96ced01"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "d247dcfda19e6551172519ac4b90ffdce262a31f95cb268284bbe16821084e31"
  end

  depends_on "go" => :build

  def install
    proj = "gitlab.com/gitlab-org/gitlab-runner"
    ldflags = %W[
      -s -w
      -X #{proj}/common.NAME=gitlab-runner
      -X #{proj}/common.VERSION=#{version}
      -X #{proj}/common.REVISION=#{Utils.git_short_head(length: 8)}
      -X #{proj}/common.BRANCH=#{version.major}-#{version.minor}-stable
      -X #{proj}/common.BUILT=#{time.strftime("%Y-%m-%dT%H:%M:%S%:z")}
    ]
    system "go", "build", *std_go_args(ldflags:)
  end

  service do
    run [opt_bin/"gitlab-runner", "run", "--syslog"]
    environment_variables PATH: std_service_path_env
    working_dir Dir.home
    keep_alive true
    macos_legacy_timers true
    process_type :interactive
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/gitlab-runner --version")
  end
end
