# Load Codex CLI completions lazily for fish.
# This script is sourced by fish when completing the `codex` command.

if type -q codex
    # Ask Codex CLI to output its fish completions, then source them.
    codex completion fish | source
end
