class AiBarracks < Formula
  desc "Git-native AI agent workspace with session tracking and persistent memory"
  homepage "https://github.com/CYRok90/ai-barracks"
  url "https://github.com/CYRok90/ai-barracks/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "fb051590852047768c381579cdff895b8bf5dd5c4506662a2266b9a353d68d4f"
  license "MIT"

  def install
    bin.install "bin/aib"
    pkgshare.install "templates"
    pkgshare.install "scripts"

    # Patch template dir path in the aib script
    inreplace bin/"aib", /^TEMPLATE_DIR=.*$/, "TEMPLATE_DIR=\"#{pkgshare}/templates\""
  end

  test do
    system bin/"aib", "version"
  end
end
