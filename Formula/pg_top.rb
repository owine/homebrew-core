class PgTop < Formula
  desc "Monitor PostgreSQL processes"
  homepage "https://pg_top.gitlab.io"
  url "https://ftp.postgresql.org/pub/projects/pgFoundry/ptop/pg_top/3.7.0/pg_top-3.7.0.tar.bz2"
  mirror "https://mirrorservice.org/sites/ftp.postgresql.org/projects/pgFoundry/ptop/pg_top/3.7.0/pg_top-3.7.0.tar.bz2"
  sha256 "c48d726e8cd778712e712373a428086d95e2b29932e545ff2a948d043de5a6a2"
  revision 4

  # 4.0.0 is out, but unfortunatley no longer supports OS/X.  Therefore
  # we only look for the latest 3.x release until upstream adds OS/X support back.
  livecheck do
    url "https://gitlab.com/pg_top/pg_top.git"
    regex(/^v?(3(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any,                 arm64_monterey: "a157f605a85907c0d04410199dfcc4d7de515844f0ad41bcbcde1b8b771431c8"
    sha256 cellar: :any,                 arm64_big_sur:  "506d2459e302e37bac0f38f99cd2cc2d3c3f5fd39631ee540a6f54d59af07f4a"
    sha256 cellar: :any,                 monterey:       "6252dc42f3d6e6570b0371f2f10cd146a06bd52b492636bbb35f62ff07239b7a"
    sha256 cellar: :any,                 big_sur:        "7980c5af9dec1de3a76a74fbd4b359ec1a90bdd7223fa7ffc8f4294642042fc8"
    sha256 cellar: :any,                 catalina:       "edf54d452403cf5be9b63a0a744560a00bb9e83ace3885ae33d36d96b0a8c2a4"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "65fe3861c5e90a4c9403f4b551892cd8ac85fbbea1cc23f551ee0eda3c9de01d"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "libpq"

  uses_from_macos "ncurses"

  def install
    system "autoreconf", "-fvi"
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-postgresql=#{Formula["libpq"].opt_prefix}"
    (buildpath/"config.h").append_lines "#define HAVE_DECL_STRLCPY 1"
    # On modern OS/X [v]snprinf() are macros that optionally add some security checks
    # In c.h this package provides their own declaration of these assuming they're
    # normal functions.  This collides with macro expansion badly but since we don't
    # need the declarations anyway just change the string to something harmless:
    inreplace "c.h", "snprintf", "unneeded_declaration_of_snprintf"
    # This file uses "vm_stats" as a symbol name which conflicts with vm_stats()
    # function in the SDK:
    inreplace "machine/m_macosx.c", "vm_stats", "vm_stats_data"
    system "make", "install"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pg_top -V")
  end
end
