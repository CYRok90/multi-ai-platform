class MultiAiPlatform < Formula
  desc "Cross-client LLM session sharing and persistent memory system"
  homepage "https://github.com/CYRok90/multi-ai-platform"
  url "https://github.com/CYRok90/multi-ai-platform/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "222ddd1c34868803dbf4b881376404413331871fc9885d723458e98be45b4f94"
  license "MIT"

  def install
    bin.install "bin/map"
    pkgshare.install "templates"
    pkgshare.install "scripts"

    # Patch template dir path in the map script
    inreplace bin/"map", /^TEMPLATE_DIR=.*$/, "TEMPLATE_DIR=\"#{pkgshare}/templates\""
  end

  test do
    system bin/"map", "version"
  end
end
