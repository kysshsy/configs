import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Widgets

FocusScope {
    id: root

    property var pluginService: null
    implicitHeight: settingsColumn.implicitHeight
    height: implicitHeight

    Column {
        id: settingsColumn
        anchors.fill: parent
        anchors.margins: 16
        spacing: Theme.spacingL

        Text {
            text: "Web Search Plugin"
            font.pixelSize: 18
            font.weight: Font.Bold
            color: "#FFFFFF"
        }

        Text {
            text: "Type the trigger followed by a search term in Spotlight, then press Enter."
            font.pixelSize: 14
            color: "#CCFFFFFF"
            wrapMode: Text.WordWrap
            width: parent.width - 32
        }

        Column {
            width: parent.width - 32
            spacing: Theme.spacingM

            Text {
                text: "Trigger"
                font.pixelSize: 14
                color: "#FFFFFF"
            }

            DankTextField {
                id: triggerField
                width: parent.width
                height: 40
                text: loadSettings("trigger", "g")
                placeholderText: "g"
                backgroundColor: "#30FFFFFF"
                textColor: "#FFFFFF"
                onTextEdited: saveSettings("trigger", text.trim() || "g")
            }

            Text {
                text: "Example: g nixos"
                font.pixelSize: 12
                color: "#AAFFFFFF"
            }
        }

        Column {
            width: parent.width - 32
            spacing: Theme.spacingM

            Text {
                text: "Search URL template"
                font.pixelSize: 14
                color: "#FFFFFF"
            }

            DankTextField {
                id: urlField
                width: parent.width
                height: 40
                text: loadSettings("searchUrlTemplate", "https://www.google.com/search?q=%s")
                placeholderText: "https://www.google.com/search?q=%s"
                backgroundColor: "#30FFFFFF"
                textColor: "#FFFFFF"
                onTextEdited: saveSettings("searchUrlTemplate", text.trim() || "https://www.google.com/search?q=%s")
            }

            Text {
                text: "Use %s where the URL-encoded search term should be inserted."
                font.pixelSize: 12
                color: "#AAFFFFFF"
                wrapMode: Text.WordWrap
                width: parent.width
            }
        }
    }

    function saveSettings(key, value) {
        if (pluginService)
            pluginService.savePluginData("webSearch", key, value);
    }

    function loadSettings(key, defaultValue) {
        if (pluginService)
            return pluginService.loadPluginData("webSearch", key, defaultValue);
        return defaultValue;
    }
}
