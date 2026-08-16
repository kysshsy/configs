import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root
    property int cpu: 0
    property real down: 0
    property real up: 0
    property string address: "Loading"
    property string cidr: "-"
    property string gateway: "-"
    property string device: "-"
    property bool mihomo: false
    property double previousTotal: 0
    property double previousIdle: 0
    property double previousRx: 0
    property double previousTx: 0
    property double previousTime: 0
    function rate(value) {
        return value < 1048576
            ? (value / 1024).toFixed(1) + " KiB/s"
            : (value / 1048576).toFixed(1) + " MiB/s";
    }

    function refresh() {
        sampler.running = true;
    }

    Timer { interval: 2000; running: true; repeat: true; onTriggered: root.refresh() }

    Process {
        id: sampler
        command: ["sh", "-c", "set -- $(awk '/^cpu / {print $2+$3+$4+$5+$6+$7+$8, $5}' /proc/stat); echo CPU:$1:$2; r=$(ip route show default | head -n1); d=$(printf '%s' \"$r\" | awk '{for(i=1;i<=NF;i++) if($i==\"dev\"){print $(i+1);exit}}'); g=$(printf '%s' \"$r\" | awk '{for(i=1;i<=NF;i++) if($i==\"via\"){print $(i+1);exit}}'); a=$(ip -o -4 addr show dev \"$d\" scope global 2>/dev/null | awk '{print $4;exit}'); set -- $(awk -F'[: ]+' -v d=\"$d\" '$1==d {print $2,$10}' /proc/net/dev); echo NET:$d:$1:$2; echo ADDR:$a; echo GW:$g; systemctl --user is-active --quiet mihomo.service && echo MIHOMO:1 || echo MIHOMO:0"]
        stdout: StdioCollector {
            onStreamFinished: {
            const now = Date.now();
            for (const line of text.trim().split("\n")) {
                const parts = line.split(":");
                if (parts[0] === "CPU") {
                    const total = Number(parts[1]);
                    const idle = Number(parts[2]);
                    if (root.previousTotal) {
                        root.cpu = Math.max(0, Math.min(100,
                            Math.round(100 * (1 - (idle - root.previousIdle)
                                / (total - root.previousTotal)))));
                    }
                    root.previousTotal = total;
                    root.previousIdle = idle;
                } else if (parts[0] === "NET") {
                    const rx = Number(parts[2]);
                    const tx = Number(parts[3]);
                    if (root.previousTime) {
                        const seconds = (now - root.previousTime) / 1000;
                        root.down = Math.max(0, (rx - root.previousRx) / seconds);
                        root.up = Math.max(0, (tx - root.previousTx) / seconds);
                    }
                    root.device = parts[1] || "-";
                    root.previousRx = rx;
                    root.previousTx = tx;
                    root.previousTime = now;
                } else if (parts[0] === "ADDR") {
                    root.cidr = parts[1] || "-";
                    root.address = root.cidr.split("/")[0] || "-";
                } else if (parts[0] === "GW") {
                    root.gateway = parts[1] || "-";
                } else if (parts[0] === "MIHOMO") {
                    root.mihomo = parts[1] === "1";
                }
            }
            }
        }
    }
    Component.onCompleted: refresh()
    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingS

            DankIcon {
                name: "pets"
                size: root.iconSize
                color: Theme.surfaceText
            }

            StyledText {
                text: root.cpu + "%"
                color: Theme.surfaceText
                font.pixelSize: Theme.fontSizeSmall
            }

            StyledText {
                text: "Down " + root.rate(root.down)
                color: Theme.surfaceText
                font.pixelSize: Theme.fontSizeSmall
            }
        }
    }
    popoutContent: Component {
        PopoutComponent {
            headerText: "System Activity"
            detailsText: root.mihomo ? "Mihomo is running" : "Mihomo is not running"
            showCloseButton: true

            Column {
                width: parent.width
                spacing: Theme.spacingM

                Repeater {
                    model: [
                        ["CPU", root.cpu + "%"],
                        ["Download", root.rate(root.down)],
                        ["Upload", root.rate(root.up)],
                        ["Interface", root.device],
                        ["Local IP", root.address],
                        ["Network", root.cidr],
                        ["Gateway", root.gateway],
                        ["Mihomo", root.mihomo ? "Active" : "Inactive"]
                    ]

                    delegate: Row {
                        width: parent.width

                        StyledText {
                            width: 112
                            text: modelData[0]
                            color: Theme.surfaceVariantText
                        }

                        StyledText {
                            text: modelData[1]
                            color: Theme.surfaceText
                        }
                    }
                }
            }
        }
    }
    popoutWidth: 360
    popoutHeight: 330
}
