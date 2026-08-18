import QtQuick
import qs.Services

QtObject {
    id: root

    property var pluginService: null
    property string trigger: "g"
    property string searchUrlTemplate: "https://www.google.com/search?q=%s"
    property string linksJson: "[{\"keyword\":\"gmail\",\"name\":\"Gmail\",\"url\":\"https://mail.google.com/\"},{\"keyword\":\"calendar\",\"name\":\"Google Calendar\",\"url\":\"https://calendar.google.com/\"}]"

    Component.onCompleted: {
        if (!pluginService)
            return;
        trigger = pluginService.loadPluginData("webSearch", "trigger", "g");
        searchUrlTemplate = pluginService.loadPluginData(
            "webSearch",
            "searchUrlTemplate",
            "https://www.google.com/search?q=%s"
        );
        linksJson = pluginService.loadPluginData("webSearch", "linksJson", linksJson);
    }

    function getItems(query) {
        const searchTerm = (query || "").trim();
        if (!searchTerm)
            return [];

        const normalizedTerm = searchTerm.toLowerCase();
        let links = [];
        try {
            links = JSON.parse(linksJson);
        } catch (e) {
            return [{
                name: "Invalid Quick Links configuration",
                icon: "material:error_outline",
                comment: "Fix the JSON in DMS Settings -> Plugins -> Quick Links",
                action: "none",
                categories: ["Quick Links"]
            }];
        }

        const matchingLinks = links.filter(function(link) {
            return link && link.keyword && link.url &&
                link.keyword.toLowerCase() === normalizedTerm;
        });

        if (matchingLinks.length > 0) {
            return matchingLinks.map(function(link) {
                return {
                    name: link.name || link.keyword,
                    icon: link.icon || "material:link",
                    comment: link.url,
                    action: "open:" + link.url,
                    categories: ["Quick Links"]
                };
            });
        }

        if (normalizedTerm.startsWith("g ") && normalizedTerm.length > 2) {
            const googleTerm = searchTerm.substring(2).trim();
            const encodedTerm = encodeURIComponent(googleTerm);
            return [{
                name: "Search Google for " + googleTerm,
                icon: "material:search",
                comment: searchUrlTemplate.replace("%s", googleTerm),
                action: "open:" + searchUrlTemplate.replace("%s", encodedTerm),
                categories: ["Quick Links"]
            }];
        }

        return [];
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

    onLinksJsonChanged: {
        if (pluginService)
            pluginService.savePluginData("webSearch", "linksJson", linksJson);
    }
}
