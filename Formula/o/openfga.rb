class Openfga < Formula
  desc "High performance and flexible authorization/permission engine"
  homepage "https://openfga.dev/"
  url "https://github.com/openfga/openfga/archive/refs/tags/v1.10.5.tar.gz"
  sha256 "a4eb2172ea1488359846c8014463e64c38a2f4edcc9274d6a597d7f5d816f7f2"
  license "Apache-2.0"
  head "https://github.com/openfga/openfga.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "f2465b738f1619ff459571f393797d6a056b8c9b1efacf642967035e5d3e549d"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "9593a9c9e786f3f762d30edd0a22868aaa54117dc2981d5ac58f503309ab0632"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "3d9c152e998762130bd3000fded22fa63455af0a24df63fdd41dc851dbcab217"
    sha256 cellar: :any_skip_relocation, sonoma:        "f4a9b87ee152af16c93241652d5403ebec6ad2d6dc4416b4f868fdd269d7ad92"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "e7250d9c575a5213053e1e85728cdc626bb1f1965d1ed5dd41785b795947ecb8"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "831b6fe5f04d8a15af894c22f06c5c96fb032d593876b09cd71955dc76478225"
  end

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X github.com/openfga/openfga/internal/build.Version=#{version}
      -X github.com/openfga/openfga/internal/build.Commit=brew
      -X github.com/openfga/openfga/internal/build.Date=#{time.iso8601}
    ]
    system "go", "build", *std_go_args(ldflags:), "./cmd/openfga"

    generate_completions_from_executable(bin/"openfga", "completion")
  end

  test do
    port = free_port
    pid = fork do
      exec bin/"openfga", "run", "--playground-port", port.to_s
    end
    sleep 3
    output = shell_output("curl -s http://localhost:#{port}/playground")
    assert_match "title=\"Embedded Playground\"", output

    assert_match version.to_s, shell_output("#{bin}/openfga version 2>&1")
  ensure
    Process.kill("SIGTERM", pid)
    Process.wait(pid)
  end
end
