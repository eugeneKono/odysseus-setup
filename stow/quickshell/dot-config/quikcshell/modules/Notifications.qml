import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import ".." as Config

PanelWindow {
    id: popupWindow

    function normalizeId(value) {
        return String(value ?? "")
            .toLowerCase()
            .replace(/\.desktop$/, "")
            .replace(/[^a-z0-9]/g, "")
    }

    function focusNotificationApp(notification) {
        const appId = notification.desktopEntry || ""
        const appName = notification.appName || ""

        if (!appId && !appName)
            return

        const entry = appId
            ? DesktopEntries.byId(appId)
            : DesktopEntries.heuristicLookup(appName)

        const candidates = [
            appId,
            entry?.id,
            entry?.startupClass,
            appName
        ]
            .map(normalizeId)
            .filter(value => value.length > 0)

        Hyprland.refreshToplevels()

        const windows = Hyprland.toplevels.values

        for (let i = 0; i < windows.length; i++) {
            const win = windows[i]
            const data = win.lastIpcObject ?? {}

            const windowClasses = [
                data.class,
                data.initialClass
            ].map(normalizeId)

            const matches = candidates.some(candidate =>
                windowClasses.some(cls => cls === candidate)
            )

            if (!matches || !win.address)
                continue

            if (win.workspace)
                win.workspace.activate()

            Hyprland.dispatch(
                `focuswindow address:${win.address}`
            )
            return
        }
    }

    required property var server

    // Configuration
    property int waybarOffset: 0
    property var notification: modelData
    property int popupWidth: 360
    property int edgeMargin: 14

    anchors {
        top: true
        right: true
    }

    margins {
        top: waybarOffset
        right: edgeMargin
    }

    implicitWidth: popupWidth
    implicitHeight: stack.implicitHeight

    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    focusable: false
    exclusiveZone: 0

    Column {
        id: stack

        width: popupWindow.popupWidth
        spacing: Config.Theme.active.spacing

        Repeater {
            model: popupWindow.server.trackedNotifications

            delegate: Rectangle {
                id: card

                required property var modelData

                property var notification: modelData
                property bool hovered: false

                width: stack.width
                implicitHeight: content.implicitHeight + 24

                radius: Config.Theme.active.radius

                color: hovered
                    ? Config.Theme.active.surfaceHover
                    : Config.Theme.active.background

                border.width: Config.Theme.active.borderWidth

                border.color: notification.urgency === 2
                    ? Config.Theme.active.red
                    : Config.Theme.active.accent

                // Accent strip
                Rectangle {
                    width: 6

                    radius: Config.Theme.active.radius

                    color: card.notification.urgency === 2
                        ? Config.Theme.active.red
                        : Config.Theme.active.accent

                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                        leftMargin: 1
                        topMargin: 10
                        bottomMargin: 10
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    z: -1

                    acceptedButtons: Qt.LeftButton
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        popupWindow.focusNotificationApp(
                            card.notification
                        )
                    }
                }

                RowLayout {
                    id: content

                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: 12
                        leftMargin: 14
                    }

                    spacing: Config.Theme.active.spacing + 2

                    // Application icon
                    Rectangle {
                        Layout.alignment: Qt.AlignTop
                        Layout.preferredWidth: 60
                        Layout.preferredHeight: 60

                        radius: Config.Theme.active.radius
                        color: "transparent"
                        clip: true

                        Image {
                            id: appIcon

                            anchors.fill: parent
                            anchors.margins: 3

                            source: {
                                const image = card.notification.image

                                if (image && image.length > 0)
                                    return image

                                const icon = card.notification.appIcon

                                if (icon && icon.length > 0) {
                                    return Quickshell.iconPath(
                                        icon,
                                        "application-x-executable"
                                    )
                                }

                                return ""
                            }

                            fillMode: Image.PreserveAspectCrop
                            smooth: true
                            mipmap: true
                            asynchronous: true
                            cache: true
                            visible: status === Image.Ready
                        }

                        Text {
                            anchors.centerIn: parent

                            text: "󰣇"

                            color: Config.Theme.active.accent

                            font.pixelSize: 48
                            font.family: Config.Theme.active.fontFamily

                            visible: !appIcon.visible
                        }
                    }

                    // Notification text
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        // Application name
                        Text {
                            Layout.fillWidth: true

                            text: {
                                const name = (
                                    card.notification.appName ||
                                    "Notification"
                                ).trim()

                                if (!name)
                                    return "Notification"

                                return name.charAt(0).toUpperCase()
                                    + name.slice(1)
                            }

                            color: Config.Theme.active.subtext

                            font.pixelSize: Config.Theme.active.fontSize - 3
                            font.weight: Font.Medium
                            font.family: Config.Theme.active.fontFamily

                            elide: Text.ElideRight
                        }

                        // Notification summary
                        Text {
                            Layout.fillWidth: true

                            text: card.notification.summary || ""

                            color: Config.Theme.active.accent

                            font.pixelSize: Config.Theme.active.fontSize - 1
                            font.weight: Font.Bold
                            font.family: Config.Theme.active.fontFamily

                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }

                        // Notification body
                        Text {
                            Layout.fillWidth: true

                            text: card.notification.body || ""

                            color: Config.Theme.active.subtext

                            font.pixelSize: Config.Theme.active.fontSize - 2
                            font.family: Config.Theme.active.fontFamily

                            wrapMode: Text.Wrap
                            maximumLineCount: 4
                            elide: Text.ElideRight

                            visible: text.length > 0
                        }
                    }

                    // Dismiss button
                    Rectangle {
                        Layout.alignment: Qt.AlignTop
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24

                        radius: Config.Theme.active.radius

                        color: closeMouse.containsMouse
                            ? Config.Theme.active.surfaceHover
                            : "transparent"

                        Text {
                            anchors.centerIn: parent

                            text: "×"

                            color: Config.Theme.active.subtext

                            font.pixelSize: 19
                            font.family: Config.Theme.active.fontFamily
                        }

                        MouseArea {
                            id: closeMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: card.notification.dismiss()
                        }
                    }
                }

                // Notification expiration
                Timer {
                    interval: card.notification.expireTimeout > 0
                        ? Math.max(
                            1500,
                            card.notification.expireTimeout * 1000
                        )
                        : 5000

                    running: !card.hovered
                    repeat: false

                    onTriggered: card.notification.expire()
                }

                HoverHandler {
                    onHoveredChanged: card.hovered = hovered
                }

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }
            }
        }
    }
}

