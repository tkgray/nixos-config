# AGENT RUNBOOK

This repository hosts a single NixOS configuration for the "seagull" system. The goal of AGENTS.md is to give future agentic tools (including you) the precise commands and style expectations needed to operate without extra context.

## 1. Environment setup

1. Clone the repo, then drop into the development shell whenever you need standard tooling:
   ```bash
   nix develop
   ```
   The shell prints a banner and exposes `nixfmt`, `nixpkgs-fmt`, `deadnix`, `statix`, and `nil`.

2. Whenever you change code, keep in mind: the system is built with flakes, so rely on flake-based commands (`nix flake check`, `nix develop`, `nix build`, etc.). Avoid older non-flake invocations.

3. The configuration files live at the repo root, primarily `configuration.nix`, `configuration-local.nix`, and `flake.nix`; refer to them before touching services or package sets.

## 2. Build / Lint / Test commands

### Build and deploy
- `sudo nixos-rebuild switch --flake .#seagull` – regenerate and activate the system configuration on the running host.
- `sudo nixos-rebuild build --flake .#seagull` – build the new configuration without switching, useful for validating changes before deployment.
- `sudo nixos-rebuild diff --flake .#seagull` – compare the current generation to the working one.
  Use `--flake .#seagull` on every rebuild command to ensure the correct configuration is used.

### Quality checks
- `nix fmt` – runs the flake-defined formatter (nixpkgs-fmt via `flake.lock`).
- `nix flake check` – executes all built-in checks (formatting, deadnix, statix).
- `nix build .#checks.x86_64-linux.formatting` – run a single quality check when you only need formatting verification.
- `nix build .#checks.x86_64-linux.deadnix` – focus on unused code detection.
- `nix build .#checks.x86_64-linux.statix` – run the static-type/analysis check alone.
  These commands reuse the flake’s check definitions so incremental iteration is fast.

### Testing guidance
- There are no dedicated test suites yet, so treat the `checks` outputs as the default verification steps.
- When someone adds additional tests later, gate them behind `nix flake check` and increment this section with specific `nix build .#checks.*` targets and how to run each test individually.

## 3. Code style guidelines

### Imports and structure
- Keep imports grouped by nature: standard module references first (`pkgs`, `config`, `lib`, etc.), then overlay definitions, then local paths.
- Prefer inheriting with `inherit` or `with` only inside a single scope; avoid repeating `pkgs.` when using `with pkgs` at the top of a block.
- When referencing local files (e.g., `./hardware-configuration.nix`), use relative paths anchored to the containing file’s directory.

### Formatting and whitespace
- Follow the formatting enforced by `nixfmt` / `nix pkgs fmt`. This means:
  - 2-space indentation inside config blocks.
  - Align multi-line lists and attribute sets for readability.
  - Keep line lengths reasonable (~80-100 characters) but prefer clarity over strict wrapping.
- Comments should explain *why* not *what*; keep them in English and avoid excessive inline commentary.

### Naming conventions
- Use lowercase-with-dashes for overlay names and attribute keys (e.g., `flake.nix` sections and module names).
- When defining module options or services, prefer self-descriptive names: `services.pipewire`, `users.users.tom`, `networking.firewall.trustedInterfaces`.
- When aliasing packages inside `environment.systemPackages`, keep the list alphabetical for easy diffing.

### Types and attribute sets
- Always use attribute sets (`{ ... }`) for configuration blocks, even if they contain a single entry, to preserve clarity in diffs.
- Use `inherit` when pulling attributes from a surrounding scope to keep assignment concise:
  ```nix
  { pkgs, ... }:
  {
    environment.systemPackages = with pkgs; [ vim wget ];
  }
  ```
- When defining lists (packages, services, interfaces), prefer multi-line formatting with trailing `]` on its own line for readability.

### Error handling and guardrails
- Keep optional flags commented with `#` explanations so future reviewers can understand why they are off.
- Services that rely on external resources (e.g., Tailscale, SABnzbd) must declare firewall allowances explicitly (`networking.firewall.trustedInterfaces`).
- If a command might fail (e.g., a build step like `deadnix --fail`), ensure the flake check wraps it in a dedicated `runCommand` with `touch $out` to keep nix aware of the result.

### Documentation style
- Mirror the README style for user-facing docs: short sentences, code blocks for commands, clear headings.
- When adding references, include the path (e.g., `configuration.nix`, `hardware-configuration.nix`).
- Update this AGENTS.md when policies evolve, and keep it near 150 lines to stay readable for other agentic tools.

## 4. Common workflows

1. After editing Nix files, run `nixfmt` (or `nix fmt`).
2. Execute the relevant check from `nix build .#checks...` to verify formatting/statics.
3. Inspect diffs (`git diff`) and only commit when the system rebuild succeeds locally with `sudo nixos-rebuild build --flake .#seagull`.
4. When collaborating, mention in your commit message which checks you ran (e.g., "ran nix fmt + nix build .#checks.x86_64-linux.statix").

## 5. Agent expectations

- Treat this repo as single-system configuration; changes should never renumber services or packages without a quick manual check of the entire config.
- Prefer minimal diffs—avoid reorganizing unrelated blocks just to reformat.
- If a change touches `configuration.nix` or `configuration-local.nix`, double-check that `nixos-rebuild switch` can finish without errors before finishing your work.
- Keep AGENTS.md up to date; add new commands or style notes as the repository grows.

## 6. Cursor / Copilot rules

- There are no `.cursor/rules/` or `.cursorrules` entries in this repo today; likewise, `.github/copilot-instructions.md` does not exist. If such rule files are introduced, include their key directives verbatim in this section so future agents do not miss restrictive heuristics or prohibited patterns.

## 7. Monitoring and verification

1. Always read `flake.nix` before assuming tooling versions: it defines the dev shell, overlays, and formatter used by downstream checks.
2. Run `nix develop` before editing so `nixfmt`, `deadnix`, `statix`, and `nil` are available without extra setup.
3. For quick local feedback, run `nix build .#checks.x86_64-linux.formatting` after formatting changes; only escalate to `nix flake check` when the change set touches multiple areas or you modified services.
4. After a successful rebuild push or switch, describe which checks completed in your commit message or PR description to help reviewers know what was verified.

## 8. Communication style

- Default to concise, friendly, factual language; treat the reader as a teammate.
- Avoid permission questions (e.g., "Should I run tests?"); instead run the reasonable default and report it.
- When unsure, do non-blocking investigation first, then ask one targeted clarifying question if absolutely necessary. Include a recommended default and describe how the answer would change the work.
- Summaries should start with a brief explanation of the change, followed by context; mention natural next steps when appropriate, using numbered lists when comparing multiple options.

## 9. File reference conventions

- Refer to files using inline code (e.g., `configuration.nix`, `flare.nix`).
- Provide single-path references per mention and allow line numbers when helpful (e.g., `configuration-local.nix:45`).
- Never cite `file://` or remote URLs when referencing workspace files.

## 10. Hip deploy reminders

1. Do not run destructive git commands (`reset --hard`, `checkout --`, etc.) unless explicitly requested.
2. Do not amend commits unless the user explicitly asks and all requirements in the runbook are satisfied.
3. Do not push to the remote unless the user asks; if you do push, use `git push` without `--force` while explaining why it is safe.

## 11. Additional tips

- When writing new services, add firewall allowances explicitly as shown by the `tailscale0` entry to avoid surprises.
- Prefer multi-line attribute sets and align closing braces for readability; this is easier after running `nix fmt`.
- Keep longer comments (over a sentence) aligned with the surrounding block so they do not disrupt the indentation.
