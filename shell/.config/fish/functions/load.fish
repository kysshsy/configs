function load --description "Load a manual fish config by name"
    if test (count $argv) -ne 1
        echo "usage: load <name>"
        return 1
    end

    set -l file ~/.config/fish/manual/$argv[1].fish

    if not test -f $file
        echo "load: file not found: $file"
        return 1
    end

    source $file
end

