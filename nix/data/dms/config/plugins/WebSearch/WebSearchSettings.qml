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
            text: "Quick Links Plugin"
            font.pixelSize: 18
            font.weight: Font.Bold
            color: "#FFFFFF"
        }

        Text {
            text: "Type a configured keyword in Spotlight to open a website. Use g followed by text for a Google search."
            font.pixelSize: 14
            color: "#CCFFFFFF"
            wrapMode: Text.WordWrap
            width: parent.width - 32
        }

        Column {
            width: parent.width - 32
            spacing: Theme.spacingM

            Text {
                text: "Google search URL template"
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

        Column {
            width: parent.width - 32
            spacing: Theme.spacingM

            Text {
                text: "Website shortcuts"
                font.pixelSize: 14
                color: "#FFFFFF"
            }

            TextEdit {
                id: linksEditor
                width: parent.width
                height: 180
                text: loadSettings("linksJson", defaultLinks)
                color: "#FFFFFF"
                font.pixelSize: 13
                wrapMode: TextEdit.Wrap
                selectByMouse: true
                persistentSelection: true
                textFormat: TextEdit.PlainText
                onTextChanged: {
                    if (activeFocus)
                        saveSettings("linksJson", text);
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -8
                    z: -1
                    radius: 4
                    color: "#30FFFFFF"
                }
            }

            Text {
                text: "Each entry needs keyword and url; name and icon are optional."
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

    readonly property string defaultLinks: "[{\"keyword\":\"gmail\",\"name\":\"Gmail\",\"url\":\"https://mail.google.com/\"},{\"keyword\":\"calendar\",\"name\":\"Google Calendar\",\"url\":\"https://calendar.google.com/\"}]"
}
