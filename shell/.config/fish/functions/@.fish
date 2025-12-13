function @ --description "Use Codex to turn natural language into a shell command"
    if test (count $argv) -eq 0
        echo "Usage: @ <describe what you want the command to do>" >&2
        return 1
    end

    # Join all arguments into a single query string
    set -l query (string join " " -- $argv)

    # Prompt for codex: ask for a single fish shell command, no explanation
    set -l prompt "You are a fish shell assistant. Based on my current directory in fish shell, output a single fish shell command that does the following: $query. The command MUST be valid in fish shell (no bash-only syntax) and should avoid glob patterns that error when there are no matches; for example, prefer 'ls -A' to show hidden files. Output only the command itself on one line, with no backticks, no code fences, and no explanations."

    # Call codex exec with the fast profile; stdout should contain the suggested command
    set -l raw (codex exec -p fast --sandbox read-only --skip-git-repo-check "$prompt" 2>/dev/null)

    if test -z "$raw"
        echo "codex exec returned empty output" >&2
        return 1
    end

    # Take the first non-empty line
    set -l first_line
    for line in (string split "\n" -- $raw)
        if test -n (string trim -- $line)
            set first_line $line
            break
        end
    end

    if test -z "$first_line"
        echo "No command found in Codex output" >&2
        return 1
    end

    # Basic cleanup in case codex ever returns fenced code
    set -l cmd (string trim -- $first_line)
    set cmd (string replace -r "^```(bash|sh)?" "" -- $cmd)
    # Use single quotes so $ is treated literally in the regex
    set cmd (string replace -r '```$' "" -- $cmd)
    set cmd (string trim -- $cmd)

    # Replace the current command line with the generated command instead of printing
    commandline -r -- $cmd
    commandline -f repaint
end
