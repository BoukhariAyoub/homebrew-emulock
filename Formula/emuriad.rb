class Emuriad < Formula
  desc "Enforced Android emulator reservations for parallel AI coding agents"
  homepage "https://github.com/BoukhariAyoub/emuriad"
  url "https://github.com/BoukhariAyoub/emuriad/archive/refs/tags/v0.3.2.tar.gz"
  sha256 "358d536d0ae588b38359a69bf905ec9a7d2362e4a88e3d1044d3c527876b9d11"
  license "MIT"
  head "https://github.com/BoukhariAyoub/emuriad.git", branch: "main"

  # jq is not a convenience here. The guard parses the agent harness's payload
  # with it, and a hook that cannot parse its input exits 0 -- which means
  # "allow". Without jq, emuriad silently enforces nothing. Homebrew declaring
  # it makes that failure mode impossible for anyone installing this way.
  depends_on "jq"
  depends_on "python@3.13"

  def install
    # emulock and emulock-lab are the pre-0.3 names: shims that run emuriad, so
    # hooks and scripts written for emulock keep working.
    bin.install "bin/emuriad", "bin/emuriad-lab", "bin/emulock", "bin/emulock-lab"
    # The pool script and the python tools (doctor, evidence, init, the dashboard)
    # are found by bin/emuriad relative to its own real path.
    libexec.install Dir["libexec/*.py"], "libexec/emuriad-pool.sh"
    pkgshare.install "hooks", "skills"
    doc.install "README.md"
  end

  def caveats
    <<~EOS
      emuriad is installed, but nothing is enforced until the guard is wired
      into your agent harness. Run this yourself, in a terminal — it shows each
      change and asks first:

        emuriad init              # ~/.claude: every project on this machine
        emuriad init --project    # or one repo's .claude/ (commit it for your team)

      It also links the agent skill, so agents claim correctly instead of
      learning the rules by being refused. Then confirm enforcement is live:

        emuriad doctor

      Coming from emulock? The emulock command still works (a shim), and
      `emuriad init` offers to move an old emulock hook and skill over.
    EOS
  end

  test do
    assert_match "emulator reservations", shell_output("#{bin}/emuriad --help")
    # A scratch store, so the test never reads or writes a real lock, and a stub
    # adb, so it passes on a machine without the Android SDK.
    ENV["EMULATOR_LOCK_DIR"] = testpath/"locks"
    (testpath/"bin/adb").write "#!/bin/sh\necho 'List of devices attached'\n"
    chmod 0755, testpath/"bin/adb"
    ENV.prepend_path "PATH", testpath/"bin"
    assert_match "SERIAL", shell_output("#{bin}/emuriad status")
    assert_path_exists pkgshare/"hooks/claude-code/emuriad-guard.sh"
    assert_path_exists pkgshare/"skills/emuriad/SKILL.md"
    assert_match "emuriad #{version}", shell_output("#{bin}/emuriad version")
    # The hook itself: kill-server is refused for everyone.
    payload = '{"session_id":"t","tool_input":{"command":"adb kill-server"}}'
    assert_match "deny", pipe_output("#{bin}/emuriad guard", payload)
    # The pre-0.3 name still runs emuriad, and still enforces as the hook.
    assert_match "emuriad #{version}", shell_output("#{bin}/emulock version 2>/dev/null")
    assert_match "deny", pipe_output("#{bin}/emulock guard", payload)
  end
end
