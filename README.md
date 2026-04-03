# office-cli Skills

This repository contains the public Codex skill for the closed-source `office-cli` product.

## Install

### One-line install

Use `wget`:

```bash
wget -qO- https://raw.githubusercontent.com/officecli/office-cli-skills/main/scripts/install-skill.sh | bash -s -- office-cli
```

Or use `curl`:

```bash
curl -fsSL https://raw.githubusercontent.com/officecli/office-cli-skills/main/scripts/install-skill.sh | bash -s -- office-cli
```

The installer will:

- install the `office-cli` skill into `~/.codex/skills`
- try to auto-install the `office-cli` binary when it is missing
- use Homebrew on macOS when available, and fall back to direct binary install when brew fails
- use the public Linux installer and install into `~/.local/bin` by default

If `office-cli` is still reported as not found after installation, first try the current-shell fix:

```bash
export PATH="$HOME/.local/bin:$PATH"
office-cli --version
```

Then add `~/.local/bin` to the startup config for your shell if needed.

Re-running the same installer command refreshes the local skill to the latest version from GitHub.

If you only want the skill and do not want to auto-install the binary:

```bash
curl -fsSL https://raw.githubusercontent.com/officecli/office-cli-skills/main/scripts/install-skill.sh | AUTO_INSTALL_BINARY=0 bash -s -- office-cli
```

### Update

To update an existing local skill from GitHub, run the same install command again:

```bash
curl -fsSL https://raw.githubusercontent.com/officecli/office-cli-skills/main/scripts/install-skill.sh | bash -s -- office-cli
```

Or with `wget`:

```bash
wget -qO- https://raw.githubusercontent.com/officecli/office-cli-skills/main/scripts/install-skill.sh | bash -s -- office-cli
```

### Manual install

Copy the skill directory into your local Codex skills directory:

```bash
mkdir -p ~/.codex/skills

tmpdir="$(mktemp -d)"
git clone https://github.com/officecli/office-cli-skills.git "$tmpdir/repo"
cp -R "$tmpdir/repo/skills/office-cli" ~/.codex/skills/
```

After copying, restart Codex.

## Scope

- Public `SKILL.md` content and examples
- No closed-source `office-cli` implementation code
- No private repository metadata or internal deployment details

## Layout

- `skills/office-cli/`: public skill definition
- `scripts/install-skill.sh`: shell installer for direct `wget` / `curl` usage
