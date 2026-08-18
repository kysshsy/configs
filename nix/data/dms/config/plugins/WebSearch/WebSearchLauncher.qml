import QtQuick
import qs.Services

QtObject {
    id: root

    property var pluginService: null
    property string trigger: "g"
    property string searchUrlTemplate: "https://www.google.com/search?q=%s"

    Component.onCompleted: {
        if (!pluginService)
            return;
        trigger = pluginService.loadPluginData("webSearch", "trigger", "g");
        searchUrlTemplate = pluginService.loadPluginData(
            "webSearch",
            "searchUrlTemplate",
            "https://www.google.com/search?q=%s"
        );
    }

    function getItems(query) {
        const searchTerm = (query || "").trim();
        if (!searchTerm)
            return [];

        return [{
            name: "Search Google for " + searchTerm,
            icon: "material:search",
            comment: searchUrlTemplate.replace("%s", searchTerm),
            action: "open:" + searchUrlTemplate.replace("%s", encodeURIComponent(searchTerm)),
            categories: ["Web Search"]
        }];
    }

    function executeItem(item) {
        if (!item || !item.action || !item.action.startsWith("open:"))
            return;
        Qt.openUrlExternally(item.action.substring(5));
    }

    onTriggerChanged: {
        if (pluginService)
            pluginService.savePluginData("webSearch", "trigger", trigger);
    }

    onSearchUrlTemplateChanged: {
        if (pluginService)
            pluginService.savePluginData("webSearch", "searchUrlTemplate", searchUrlTemplate);
    }
}
