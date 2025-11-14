class Bbtools < Formula
  desc "Brian Bushnell's tools for manipulating reads"
  homepage "https://jgi.doe.gov/data-and-tools/software-tools/bbtools/"
  url "https://downloads.sourceforge.net/bbmap/BBMap_39.47.tar.gz"
  sha256 "19f830432f93abf987e3070a4faa42dafe76b2ab15786f7f68ffda654ee5b0bb"
  license "BSD-3-Clause"

  bottle do
    sha256 cellar: :any,                 arm64_tahoe:   "121a9d46269c9c29e14241c7c5ed8c345d2e2c91038eee26ff9acb9dce0c3cdf"
    sha256 cellar: :any,                 arm64_sequoia: "96e7fbe747f6f711a236f4f921c08b50ec96a8ceccbfd5109cf4460ff4c40891"
    sha256 cellar: :any,                 arm64_sonoma:  "a704041f6a8a02ecab1fb4e842548ca5b5433395c3c460aa49760c9b9031aa80"
    sha256 cellar: :any,                 sonoma:        "909bebbb97b17783a23884c030fae73895712765d90905225a8a34c20df9bf47"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "17a8330c9cc2705f055d7418faabb5164fffe5735fe0cd95cc184a0c00823e2b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "4b61836cf8ae98c464457fb2f053548a6ed31dee6b47c97d2a16e2e3271f92e5"
  end

  depends_on "openjdk"

  def install
    cd "jni" do
      rm Dir["libbbtoolsjni.*", "*.o"]
      system "make", "-f", OS.mac? ? "makefile.osx" : "makefile.linux"
    end
    libexec.install %w[current jni resources]
    libexec.install Dir["*.sh"]
    bin.install Dir[libexec/"*.sh"]
    bin.env_script_all_files(libexec, Language::Java.overridable_java_home_env)
    doc.install Dir["docs/*"]
  end

  test do
    res = libexec/"resources"
    args = %W[in=#{res}/sample1.fq.gz
              in2=#{res}/sample2.fq.gz
              out=R1.fastq.gz
              out2=R2.fastq.gz
              ref=#{res}/phix174_ill.ref.fa.gz
              k=31
              hdist=1]

    system bin/"bbduk.sh", *args
    assert_match "bbushnell@lbl.gov", shell_output("#{bin}/bbmap.sh")
    assert_match "maqb", shell_output("#{bin}/bbmap.sh --help 2>&1")
    assert_match "minkmerhits", shell_output("#{bin}/bbduk.sh --help 2>&1")
  end
end
