class N8nMcp < Formula
  desc "MCP for Claude Desktop, Claude Code, Windsurf, Cursor to build n8n workflows"
  homepage "https://www.n8n-mcp.com/"
  url "https://registry.npmjs.org/n8n-mcp/-/n8n-mcp-2.22.17.tgz"
  sha256 "ff98396c2a9be37decef0187d8bb3f1098bcc5206706c43d726cf538d1cda465"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "8b5c5f104751067259977a89f3012874391f48e6425a3891d6c9117d40bc656a"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "df458403627a189a4688efa898a24581dc8651dbe3cccff3fd1124cdcac61842"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "e04fa08ca4baf89dee4f64f8b06fc507fde913a44fc4dca611a7901c6a63d4bf"
    sha256 cellar: :any_skip_relocation, sonoma:        "fa3ba9fec56b4b9c3df57e8f177c9ddb6f8fe7936dcc89690746e2b49ffbe534"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "7c40cb73a028996b3b07b9e037c42ebc197300023c5166f0a4be17dec2f09557"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "a054ffc6ef0ba54858a7bf0f95a43f17a734d415dc5de413d2b9f0d698537740"
  end

  depends_on "node@22"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    ENV["N8N_API_URL"] = "https://your-n8n-instance.com"
    ENV["N8N_API_KEY"] = "your-api-key"

    output_log = testpath/"output.log"
    pid = spawn bin/"n8n-mcp", testpath, [:out, :err] => output_log.to_s
    sleep 10
    sleep 5 if OS.mac? && Hardware::CPU.intel?
    assert_match "n8n Documentation MCP Server running on stdio transport", output_log.read
  ensure
    Process.kill("TERM", pid)
    Process.wait(pid)
  end
end
