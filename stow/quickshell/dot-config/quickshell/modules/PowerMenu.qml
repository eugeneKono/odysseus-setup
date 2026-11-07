import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import ".." as Config

// Futuristic HUD-style power interface, themed with Nord.
PanelWindow {
    id: root

    // Keep the dialog on the monitor that currently has focus.
    readonly property var focusedScreen: {
        const monitor = Hyprland.focusedMonitor

        if (monitor) {
            for (let i = 0; i < Quickshell.screens.length; i++) {
                if (Quickshell.screens[i].name === monitor.name)
                    return Quickshell.screens[i]
            }
        }

        return Quickshell.screens.length > 0
            ? Quickshell.screens[0]
            : null
    }

    screen: root.focusedScreen

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    visible: false
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:powerMenu"
    WlrLayershell.keyboardFocus: root.opened
        ? WlrKeyboardFocus.Exclusive
        : WlrKeyboardFocus.None

    readonly property QtObject theme: Config.Theme.active

    property bool opened: false
    property real reveal: 0
    property int selectedIndex: 1
    property bool readyVisible: true

    readonly property int buttonSpacing: 14
    readonly property int dialogWidth: 600
    readonly property int dialogHeight: 310

    readonly property var actions: [
        {
            label: "LOG OUT",
            icon: "\uF08B", // nf-fa-sign_out
            accent: "yellow",
            command: ["hyprctl", "dispatch", "hl.dsp.exit()"]
        },
        {
            label: "SHUTDOWN",
            icon: "\uF011", // nf-fa-power_off
            accent: "red",
            command: ["systemctl", "poweroff"]
        },
        {
            label: "REBOOT",
            icon: "\uF021", // nf-fa-refresh
            accent: "green",
            command: ["systemctl", "reboot"]
        }
    ]

    function open(): void {
        if (root.opened)
            return

        closeAnimation.stop()
        root.opened = true
        root.visible = true
        root.selectedIndex = 1
        root.reveal = 0
        root.readyVisible = true
        openAnimation.restart()

        Qt.callLater(() => keyCatcher.forceActiveFocus())
    }

    function close(): void {
        if (!root.opened)
            return

        root.opened = false
        root.readyVisible = true
        openAnimation.stop()
        closeAnimation.restart()
    }

    function activate(index: int): void {
        const action = root.actions[index]

        if (!action)
            return

        root.close()
        Quickshell.execDetached(action.command)
    }

    IpcHandler {
        target: "powerMenu"

        function toggle(): void {
            if (root.opened)
                root.close()
            else
                root.open()
        }

        function open(): void {
            root.open()
        }

        function close(): void {
            root.close()
        }
    }

    NumberAnimation {
        id: openAnimation

        target: root
        property: "reveal"
        from: 0
        to: 1
        duration: 150
        easing.type: Easing.OutCubic
    }

    NumberAnimation {
        id: closeAnimation

        target: root
        property: "reveal"
        to: 0
        duration: 120
        easing.type: Easing.InCubic

        onFinished: {
            if (!root.opened)
                root.visible = false
        }
    }

    // Dimmed backdrop. Clicking outside the dialog cancels.
    Rectangle {
        id: backdrop

        anchors.fill: parent
        color: "#000000"
        opacity: root.reveal * 0.62

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }
    }

    // HUD terminal dialog
    Rectangle {
        id: dialog

        anchors.centerIn: parent
        width: root.dialogWidth
        height: root.dialogHeight

        radius: root.theme.radius
        color: root.theme.background 

        border.width: 2
        border.color: root.theme.accent

        opacity: root.reveal
        scale: 0.96 + 0.04 * root.reveal

        // Swallow clicks so the backdrop does not close the dialog.
        MouseArea {
            anchors.fill: parent
        } 

        // Header bar (no filled background, just the interface row).
        Item {
            id: header

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: 50

            Row {
                anchors {
                    left: parent.left
                    leftMargin: 24
                    verticalCenter: parent.verticalCenter
                }
                spacing: 10

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "\udb82\udcc7" // nf-md-arch
                    color: root.theme.accent
                    font.family: root.theme.fontFamily
                    font.pixelSize: 30
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "ODYSSEUS"
                    color: root.theme.accent
                    font.family: root.theme.fontFamily
                    font.pixelSize: 24
                    font.bold: true
                    font.letterSpacing: 1.3
                }
            }

            Text {
                anchors {
                    right: parent.right
                    rightMargin: 24
                    verticalCenter: parent.verticalCenter
                }
                text: "SYS.ONLINE"
                color: root.theme.accent
                font.family: root.theme.fontFamily
                font.pixelSize: 10
                font.bold: true
                font.letterSpacing: 1.5
            }
        }

        // Header/body separation line.
        Item {
            id: separator

            anchors {
                top: header.bottom
                left: parent.left
                right: parent.right
                leftMargin: 24
                rightMargin: 24
            }
            height: 2

            Rectangle {
                anchors.fill: parent
                color: root.theme.accent
                opacity: 1.0
            }
        }

        // Dialog body
        Column {
            id: body

            anchors {
                top: separator.bottom
                left: parent.left
                right: parent.right
                leftMargin: 24
                rightMargin: 24
                topMargin: 16
            }
            spacing: 16

            Row {
                id: buttonRow

                width: parent.width
                spacing: root.buttonSpacing

                Repeater {
                    model: root.actions

                    delegate: Rectangle {
                        id: powerButton

                        required property int index
                        required property var modelData

                        readonly property bool selected:
                            root.selectedIndex === index

                        readonly property color actionColor: {
                            const themeColor = root.theme[modelData.accent]

                            return themeColor === undefined
                                ? root.theme.accent
                                : themeColor
                        }

                        readonly property bool hovered:
                            hoverArea.containsMouse

                        readonly property color displayColor:
                            hovered ? actionColor : root.theme.accent

                        width: (buttonRow.width
                            - root.buttonSpacing * 2) / 3
                        height: 160

                        radius: root.theme.radius
                        color: selected
                            ? Qt.rgba(
                                displayColor.r,
                                displayColor.g,
                                displayColor.b,
                                0.10
                            )
                            : Qt.rgba(1, 1, 1, 0.015)
                        border.width: 2
                        border.color: selected
                            ? displayColor
                            : Qt.rgba(
                                root.theme.accent.r,
                                root.theme.accent.g,
                                root.theme.accent.b,
                                0.16
                            )

                        Behavior on color {
                            ColorAnimation {
                                duration: 120
                            }
                        }

                        Behavior on border.color {
                            ColorAnimation {
                                duration: 120
                            }
                        }

                        // Highlighted top edge.
                        Rectangle {
                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                            }
                            height: 2

                            color: powerButton.displayColor
                            opacity: powerButton.selected ? 1 : 0

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 120
                                }
                            }
                        }

                        // Index tag.
                        Text {
                            anchors {
                                top: parent.top
                                left: parent.left
                                margins: 12
                            }

                            text: "0" + (powerButton.index + 1)
                            color: powerButton.selected
                                ? powerButton.displayColor
                                : root.theme.textSubtle
                            opacity: powerButton.selected ? 0.9 : 0.35

                            font.family: root.theme.fontFamily
                            font.pixelSize: 9
                            font.letterSpacing: 1.5
                        }

                        // Status square.
                        Rectangle {
                            anchors {
                                top: parent.top
                                right: parent.right
                                margins: 12
                            }
                            width: 6
                            height: 6

                            color: powerButton.selected
                                ? powerButton.displayColor
                                : "transparent"
                            border.width: 1
                            border.color: powerButton.selected
                                ? powerButton.displayColor
                                : Qt.rgba(
                                    root.theme.accent.r,
                                    root.theme.accent.g,
                                    root.theme.accent.b,
                                    0.3
                                )

                            Behavior on color {
                                ColorAnimation {
                                    duration: 120
                                }
                            }

                            Behavior on border.color {
                                ColorAnimation {
                                    duration: 120
                                }
                            }
                        }

                        MouseArea {
                            id: hoverArea

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.selectedIndex = powerButton.index
                            onClicked: root.activate(powerButton.index)
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 16

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: powerButton.modelData.icon
                                color: powerButton.displayColor
                                opacity: powerButton.selected ? 1 : 0.78

                                font.family: root.theme.fontFamily
                                font.pixelSize: 52

                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 120
                                    }
                                }
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: powerButton.modelData.label.toUpperCase()
                                color: powerButton.selected
                                    ? root.theme.text
                                    : root.theme.textMuted

                                font.family: root.theme.fontFamily
                                font.pixelSize: 13
                                font.bold: powerButton.selected
                                font.letterSpacing: 1.3

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 120
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Button/footer separation line.
            Item {
                id: footerSeparator

                width: parent.width
                height: 2

                Rectangle {
                    anchors.fill: parent
                    color: root.theme.accent
                    opacity: 1.0
                }
            }

            // Footer
            Item {
                width: parent.width
                height: 30

                Text {
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                    }

                    text: "ODYSSEUS OS -- POWER INTERFACE"
                    color: root.theme.accent

                    font.family: root.theme.fontFamily
                    font.pixelSize: 12
                    font.letterSpacing: 1.3
                }

                Row {
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 7

                    Text {
                        text: "●"
                        color: root.theme.green

                        font.family: root.theme.fontFamily
                        font.pixelSize: 12
                    }

                    Text {
                        text: "READY"
                        color: root.theme.green
                        opacity: root.readyVisible ? 1 : 0

                        font.family: root.theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        font.letterSpacing: 1.3
                    }
                }

                Timer {
                    interval: 500
                    repeat: true
                    running: root.opened
                    onTriggered: root.readyVisible = !root.readyVisible
                }
            }
        }
    }

    // Keyboard handling
    Item {
        id: keyCatcher

        anchors.fill: parent
        focus: true

        Keys.onPressed: function(event) {
            if (!root.opened)
                return

            switch (event.key) {
            case Qt.Key_Escape:
                root.close()
                event.accepted = true
                break

            case Qt.Key_Left:
            case Qt.Key_Up:
            case Qt.Key_Backtab:
                root.selectedIndex =
                    (root.selectedIndex + root.actions.length - 1)
                    % root.actions.length
                event.accepted = true
                break

            case Qt.Key_Right:
            case Qt.Key_Down:
            case Qt.Key_Tab:
                root.selectedIndex =
                    (root.selectedIndex + 1) % root.actions.length
                event.accepted = true
                break

            case Qt.Key_Return:
            case Qt.Key_Enter:
            case Qt.Key_Space:
                root.activate(root.selectedIndex)
                event.accepted = true
                break
            }
        }
    }
}
