class Emulock < Formula
  desc "Enforced Android emulator reservations for parallel AI coding agents"
  homepage "https://github.com/BoukhariAyoub/emulock"
  url "https://github.com/BoukhariAyoub/emulock/archive/refs/tags/v0.2.2.tar.gz"
  sha256 "c0440dadb1db1586b10fe054746c3a1ee23c63a90362f8cc5957d7daa63a7ad6"
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
    # The pool script and the python tools (doctor, evidence, init, the dashboard)
    # are found by bin/emulock relative to its own real path.
    libexec.install Dir["libexec/*.py"], "libexec/emulock-pool.sh"
    pkgshare.install "hooks", "skills"
    doc.install "README.md"
  end

  def caveats
    <<~EOS
      emulock is installed, but nothing is enforced until the guard is wired
      into your agent harness. Run this yourself, in a terminal — it shows each
      change and asks first:

        emulock init              # ~/.claude: every project on this machine
        emulock init --project    # or one repo's .claude/ (commit it for your team)

      It also links the agent skill, so agents claim correctly instead of
      learning the rules by being refused. Then confirm enforcement is live:

        emulock doctor
    EOS
  end

  test do
    assert_match "emulator reservations", shell_output("#{bin}/emulock --help")
    # A scratch store, so the test never reads or writes a real lock.
    ENV["EMULATOR_LOCK_DIR"] = testpath/"locks"
    assert_match "SERIAL", shell_output("#{bin}/emulock status")
    assert_predicate pkgshare/"hooks/claude-code/emulock-guard.sh", :exist?
    assert_predicate pkgshare/"skills/emulock/SKILL.md", :exist?
    assert_match "emulock 0.2.2", shell_output("#{bin}/emulock version")
    # The hook itself: kill-server is refused for everyone.
    payload = '{"session_id":"t","tool_input":{"command":"adb kill-server"}}'
    assert_match "deny", pipe_output("#{bin}/emulock guard", payload)
  end
end
