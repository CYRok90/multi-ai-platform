class MultiAiPlatform < Formula
  desc "Cross-client LLM session sharing and persistent memory system"
  homepage "https://github.com/CYRok90/multi-ai-platform"
  url "https://github.com/CYRok90/multi-ai-platform/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "19991e338af3fadf03d4f9f535cd790e7034b5c319f95cee8d7993144596e17f"
  license "MIT"

  def install
    bin.install "bin/map"
    pkgshare.install "templates"

    # Patch template dir path in the map script
    inreplace bin/"map", /^TEMPLATE_DIR=.*$/, "TEMPLATE_DIR=\"#{pkgshare}/templates\""
  end

  test do
    system bin/"map", "version"
  end
end
