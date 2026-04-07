class MultiAiPlatform < Formula
  desc "Cross-client LLM session sharing and persistent memory system"
  homepage "https://github.com/CYRok90/multi-ai-platform"
  url "https://github.com/CYRok90/multi-ai-platform/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "ddaed3aabdcaba4b6c4b28e04b9b7145eb76079382e56f4dd7062459986114db"
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
