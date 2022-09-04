class Libadwaita < Formula
  desc "Building blocks for modern adaptive GNOME applications"
  homepage "https://gnome.pages.gitlab.gnome.org/libadwaita/"
  url "https://download.gnome.org/sources/libadwaita/1.1/libadwaita-1.1.5.tar.xz"
  sha256 "e170a658b5a83226912ecd90ba643015c8d2b8bbd6ea91ebe336dfebb584bb33"
  license "LGPL-2.1-or-later"

  # libadwaita doesn't use GNOME's "even-numbered minor is stable" version
  # scheme. This regex is the same as the one generated by the `Gnome` strategy
  # but it's necessary to avoid the related version scheme logic.
  livecheck do
    url :stable
    regex(/libadwaita-(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 arm64_monterey: "80af80e6aeb78c056bd8313bdf9e98dcb240c3fdd603d050f794584efd4b362c"
    sha256 arm64_big_sur:  "d3b77cbf21cc58eb8d00a75c5815b3b47619cd359dcf9f20335a13f91f037b3a"
    sha256 monterey:       "3571c3055eb2a1c3e0d360be4ac0368458bb6c1ebeb32f8ebffe8c3e5539ef11"
    sha256 big_sur:        "e505dcfa84381cc63fc7d92b02ceb19818c1d7ebb2d71719d954c40796118a2a"
    sha256 catalina:       "a1c88bdf2a5fe98394de384ca95b28d571a258bc19cc50bf775d6b16f09afe81"
    sha256 x86_64_linux:   "8961a3d64dfb684eba91e7b7501b3cf14dc7d15580f2a052489055255d01a910"
  end

  depends_on "gobject-introspection" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "sassc" => :build
  depends_on "vala" => :build
  depends_on "gtk4"

  def install
    system "meson", "setup", "build", *std_meson_args, "-Dtests=false"
    system "meson", "compile", "-C", "build"
    system "meson", "install", "-C", "build"
  end

  test do
    # Remove when `jpeg-turbo` is no longer keg-only.
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["jpeg-turbo"].opt_lib/"pkgconfig"

    (testpath/"test.c").write <<~EOS
      #include <adwaita.h>

      int main(int argc, char *argv[]) {
        g_autoptr (AdwApplication) app = NULL;
        app = adw_application_new ("org.example.Hello", G_APPLICATION_FLAGS_NONE);
        return g_application_run (G_APPLICATION (app), argc, argv);
      }
    EOS
    flags = shell_output("#{Formula["pkg-config"].opt_bin}/pkg-config --cflags --libs libadwaita-1").strip.split
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test", "--help"

    # include a version check for the pkg-config files
    assert_match version.to_s, (lib/"pkgconfig/libadwaita-1.pc").read
  end
end
