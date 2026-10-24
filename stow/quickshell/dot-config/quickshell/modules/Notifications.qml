import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import "../theme" as Theme

PanelWindow {
    id: popupWindow

    required property var server

    // Adjust this to match your Waybar height plus a little gap.
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
        spacing: Theme.Nord.spacing

        Repeater {
            model: popupWindow.server.trackedNotifications

            delegate: Rectangle {
                id: card

                required property var modelData

                property var notification: modelData
                property bool hovered: false

                width: stack.width
                implicitHeight: content.implicitHeight + 24

                radius: Theme.Nord.radius
                color: hovered
                    ? Theme.Nord.surface
                    : Theme.Nord.background

                border.width: 2
                border.color: notification.urgency === 2
                    ? Theme.Nord.red
                    : Theme.Nord.accentAlt

                // Drop-shadoi-like accent strip.
                Rectangle {
                    width: 6
                    radius: 0
                    color: card.notification.urgency === 2
                        ? Theme.Nord.red
                        : Theme.Nord.accent

                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                        leftMargin: 1
                        topMargin: 10
                        bottomMargin: 10
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

                    spacing: 10

                    // Application icon with a fallback glyph.
                    Rectangle {
                        Layout.alignment: Qt.AlignTop
                        Layout.preferredWidth: 60
                        Layout.preferredHeight: 60

                        radius: 0
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
                            color: Theme.Nord.accent
                            font.pixelSize: 48
                            font.family: Theme.Nord.fontFamily
                            visible: !appIcon.visible
                          }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            Layout.fillWidth: true

                            text: {
                              const name = (card.notification.appName || "Notification").trim()
                              if (!name) return "Notification"

                              return name.charAt(0).toUpperCase() + name.slice(1)
                            }
                            color: Theme.Nord.textMuted
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            font.family: Theme.Nord.fontFamily

                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true

                            text: card.notification.summary || ""
                            color: Theme.Nord.accent
                            font.pixelSize: 13
                            font.weight: Font.Bold
                            font.family: Theme.Nord.fontFamily

                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true

                            text: card.notification.body || ""
                            color: Theme.Nord.textMuted
                            font.pixelSize: 12
                            font.family: Theme.Nord.fontFamily

                            wrapMode: Text.Wrap
                            maximumLineCount: 4
                            elide: Text.ElideRight
                            visible: text.length > 0
                        }
                    }

                    // Dismiss button.
                    Rectangle {
                        Layout.alignment: Qt.AlignTop
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24

                        radius: 0
                        color: closeMouse.containsMouse
                            ? Theme.Nord.surfaceHover
                            : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "×"
                            color: Theme.Nord.textMuted
                            font.pixelSize: 19
                            font.family: Theme.Nord.fontFamily
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

                // The notification disappears after its timeout.
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
