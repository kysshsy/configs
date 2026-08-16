function proxy --description "Control a running Mihomo controller"
    set -l config_home "$HOME/.config"
    if set -q XDG_CONFIG_HOME
        set config_home "$XDG_CONFIG_HOME"
    end

    set -l config_dir "$config_home/mihomo-cli"
    set -l config_file "$config_dir/config.fish"
    if test -f "$config_file"
        source "$config_file"
    end

    set -l controller "http://127.0.0.1:9097"
    set -l default_group "GLOBAL"
    if set -q MIHOMO_CLI_CONTROLLER
        set controller "$MIHOMO_CLI_CONTROLLER"
    end
    if set -q MIHOMO_CLI_DEFAULT_GROUP
        set default_group "$MIHOMO_CLI_DEFAULT_GROUP"
    end

    set -l authorization
    if set -q MIHOMO_CLI_SECRET; and test -n "$MIHOMO_CLI_SECRET"
        set authorization -H "Authorization: Bearer $MIHOMO_CLI_SECRET"
    end

    set -l command status
    if test (count $argv) -gt 0
        set command $argv[1]
    end

    switch $command
        case setup
            read -P "Mihomo controller [$controller]: " -l input_controller
            if test -n "$input_controller"
                set controller "$input_controller"
            end

            read -P "Default proxy group [$default_group]: " -l input_group
            if test -n "$input_group"
                set default_group "$input_group"
            end

            read -s -P "Controller secret (leave blank when unset): " -l secret
            echo

            command mkdir -p "$config_dir"
            command chmod 700 "$config_dir"
            begin
                echo "# Private Mihomo controller settings. Do not commit this file."
                printf "set -gx MIHOMO_CLI_CONTROLLER %s\n" (string escape -- "$controller")
                printf "set -gx MIHOMO_CLI_DEFAULT_GROUP %s\n" (string escape -- "$default_group")
                printf "set -gx MIHOMO_CLI_SECRET %s\n" (string escape -- "$secret")
            end > "$config_file"
            command chmod 600 "$config_file"
            echo "Saved controller settings to $config_file"

        case status
            command curl --silent --show-error --fail $authorization "$controller/version" | jq
            command curl --silent --show-error --fail $authorization "$controller/configs" | jq '{mode, port, "mixed-port": ."mixed-port", "external-controller": ."external-controller"}'

        case subscriptions providers
            command curl --silent --show-error --fail $authorization "$controller/providers/proxies" \
                | jq -r '.providers | to_entries[] | [.key, .value.type, .value.updatedAt] | @tsv'

        case update
            if test (count $argv) -lt 2
                echo "Usage: proxy update <subscription>" >&2
                return 2
            end
            set -l provider (string escape --style=url -- "$argv[2]")
            command curl --silent --show-error --fail --request PUT $authorization \
                "$controller/providers/proxies/$provider"
            echo "Updated subscription: $argv[2]"

        case groups
            command curl --silent --show-error --fail $authorization "$controller/proxies" \
                | jq -r '.proxies | to_entries[] | select(.value.type == "Selector" or .value.type == "URLTest" or .value.type == "Fallback" or .value.type == "LoadBalance") | .key'

        case nodes
            set -l group "$default_group"
            if test (count $argv) -gt 1
                set group "$argv[2]"
            end
            set -l escaped_group (string escape --style=url -- "$group")
            command curl --silent --show-error --fail $authorization "$controller/proxies/$escaped_group" \
                | jq -r '.all[]?'

        case use
            if test (count $argv) -lt 2
                echo "Usage: proxy use <node> [group]" >&2
                return 2
            end
            set -l group "$default_group"
            if test (count $argv) -gt 2
                set group "$argv[3]"
            end
            set -l escaped_group (string escape --style=url -- "$group")
            set -l payload (jq -n --arg name "$argv[2]" '{name: $name}')
            command curl --silent --show-error --fail --request PUT $authorization \
                --header "Content-Type: application/json" --data "$payload" \
                "$controller/proxies/$escaped_group"
            echo "Selected $argv[2] for $group"

        case mode
            if test (count $argv) -eq 1
                command curl --silent --show-error --fail $authorization "$controller/configs" | jq -r '.mode'
                return
            end
            if not contains -- "$argv[2]" rule global direct
                echo "Mode must be rule, global, or direct" >&2
                return 2
            end
            set -l payload (jq -n --arg mode "$argv[2]" '{mode: $mode}')
            command curl --silent --show-error --fail --request PATCH $authorization \
                --header "Content-Type: application/json" --data "$payload" "$controller/configs"
            echo "Mode: $argv[2]"

        case help -h --help
            echo "Usage: proxy <command>"
            echo "  setup                         Save private controller settings"
            echo "  status                        Show core version and mode"
            echo "  subscriptions | providers     List configured subscriptions"
            echo "  update <subscription>         Refresh one subscription"
            echo "  groups                        List selectable proxy groups"
            echo "  nodes [group]                 List nodes in a group"
            echo "  use <node> [group]            Select a node"
            echo "  mode [rule|global|direct]     Show or switch traffic mode"

        case '*'
            echo "Unknown proxy command: $command" >&2
            proxy help
            return 2
    end
end
