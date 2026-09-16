class Emulock < Formula
  desc "Enforced Android emulator reservations for parallel AI coding agents"
  homepage "https://github.com/BoukhariAyoub/emulock"
  url "https://github.com/BoukhariAyoub/emulock/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "677e910682eaf3d2e30480a18a3cb434fdcf7976804b29afe016902cb2e0cce7"
  license "MIT"
  head "https://github.com/BoukhariAyoub/emulock.git", branch: "main"

  # jq is not a convenience here. The guard parses the agent harness's payload
  # with it, and a hook that cannot parse its input exits 0 -- which means
  # "allow". Without jq, emulock silently enforces nothing. Homebrew declaring
  # it makes that failure mode impossible for anyone installing this way.
  depends_on "jq"
  depends_on "python@3.13"

  def install
    bin.install "bin/emulock", "bin/emulock-lab"
    libexec.install "libexec/device_lab.py"
    pkgshare.install "hooks", "skills"
    doc.install "README.md"
  end

  def caveats
    <<~EOS
      emulock is installed, but nothing is enforced until you wire the guard
      into your agent harness. This step is deliberately manual: a hook decides
      which commands an agent may run, and a hook an agent could install is one
      it could also remove.

      Add this to .claude/settings.json in each repo you want protected, then
      commit it so every contributor is covered:

        {
          "hooks": {
            "PreToolUse": [
              {
                "matcher": "Bash",
                "hooks": [
                  { "type": "command", "command": "#{pkgshare}/hooks/claude-code/emulock-guard.sh" }
                ]
              }
            ]
          }
        }

      Teach your agents the protocol too, so they claim correctly instead of
      learning the rules by being refused:

        cp -R #{pkgshare}/skills/emulock .claude/skills/

      Then confirm enforcement is actually live:

        emulock doctor
    EOS
  end

  test do
    assert_match "emulator reservations", shell_output("#{bin}/emulock --help")
    # A scratch store, so the test never reads or writes a real lock.
    ENV["EMULATOR_LOCK_DIR"] = testpath/"locks"
    assert_match "SERIAL", shell_output("#{bin}/emulock status")
    assert_predicate pkgshare/"hooks/claude-code/emulock-guard.sh", :exist?
  end
end
