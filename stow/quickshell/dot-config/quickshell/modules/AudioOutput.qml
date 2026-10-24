
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import Quickshell.Io

// Small anchor window for the popup.
PanelWindow {
    id: root

    anchors {
        top: true
        right: true
    }

    implicitWidth: 1
    implicitHeight: 1
    color: "transparent"

    // Track the current output sink so its audio properties are valid.
    PwObjectTracker {
        objects: Pipewire.defaultAudioSink
            ? [Pipewire.defaultAudioSink]
            : []
    }

    Connections {
        target: Pipewire

        function onDefaultAudioSinkChanged() {
            console.log(
                "[AudioOutput] Active sink:",
                Pipewire.defaultAudioSink
                    ? Pipewire.defaultAudioSink.description
                    : "null"
            )
        }

        function onDefaultConfiguredAudioSinkChanged() {
            console.log(
                "[AudioOutput] Preferred sink:",
                Pipewire.preferredDefaultAudioSink
                    ? Pipewire.preferredDefaultAudioSink.description
                    : "null"
            )
        }
    }
    // Nord palette
    readonly property color bg:           "#2E3440"
    readonly property color surface:      "#3B4252"
    readonly property color surfaceHover: "#434C5E"
    readonly property color borderColor:  "#88C0D0"
    readonly property color textColor:    "#ECEFF4"
    readonly property color mutedColor:   "#D8DEE9"
    readonly property color accentColor:  "#88C0D0"

    // Layout
    readonly property int popupMargin: 16
    readonly property int rowHeight: 40
    readonly property int volumeHeight: 42
    readonly property int itemSpacing: 8
    readonly property int headerHeight: 22
    readonly property int statusHeight: 14

    // Available audio output devices
    property var audioDevices: Pipewire.nodes.values.filter(node =>
        node.isSink &&
        !node.isStream &&
        node.audio !== null
    )

    // Calculate popup height
    readonly property int deviceListHeight:
        audioDevices.length * rowHeight +
        Math.max(0, audioDevices.length - 1) * itemSpacing

    readonly property int popupHeight:
        popupMargin * 2 +
        headerHeight +
        statusHeight +
        volumeHeight +
        itemSpacing * 3 +
        deviceListHeight

    // IPC controls
    IpcHandler {
        target: "audioOutput"

        function toggle(): void {
            popup.visible = !popup.visible
        }

        function close(): void {
            popup.visible = false
        }
    }

    // Audio output popup
    PopupWindow {
        id: popup

        anchor.window: root
        anchor.rect.x: root.width - width - 14
        anchor.rect.y: 14

        implicitWidth: 350
        implicitHeight: root.popupHeight

        visible: false
        grabFocus: true
        color: "transparent"

        Rectangle {
            anchors.fill: parent

            color: root.bg
            radius: 0
            border.width: 2
            border.color: root.borderColor
            clip: true

            Column {
                id: contentColumn

                anchors.fill: parent
                anchors.margins: root.popupMargin
                spacing: root.itemSpacing

                // Title
                Text {
                    text: "Audio Output"
                    color: root.textColor
                    font.pixelSize: 18
                    font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                }

                // PipeWire status
                Text {
                    text: "PipeWire ready: " + Pipewire.ready
                    color: root.mutedColor
                    font.pixelSize: 12
                    font.family: "JetBrainsMono Nerd Font"
                    opacity: 0.7
                }

                // Master volume
                Row {
                    width: contentColumn.width
                    height: root.volumeHeight
                    spacing: 10

                    Text {
                        width: 20
                        height: parent.height

                        text: "󰕾"
                        color: root.textColor
                        verticalAlignment: Text.AlignVCenter

                        font.pixelSize: 20
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                    }

                    Slider {
                        id: volumeSlider

                        width: parent.width - 40 - 50
                        height: parent.height

                        from: 0.0
                        to: 1.0
                        stepSize: 0.01

                        enabled: Pipewire.defaultAudioSink !== null
                            && Pipewire.defaultAudioSink.audio !== null

                        value: enabled
                            ? Pipewire.defaultAudioSink.audio.volume
                            : 0

                        onMoved: {
                            const sink = Pipewire.defaultAudioSink

                            if (sink && sink.audio)
                                sink.audio.volume = value
                        }

                        WheelHandler {
                            acceptedDevices:
                                PointerDevice.Mouse |
                                PointerDevice.TouchPad

                            target: null

                            onWheel: function(event) {
                                if (!volumeSlider.enabled)
                                    return

                                const delta = event.angleDelta.y

                                if (delta === 0)
                                    return

                                const step = volumeSlider.stepSize
                                const newValue = volumeSlider.value
                                    + (delta > 0 ? step : -step)

                                volumeSlider.value = Math.max(
                                    volumeSlider.from,
                                    Math.min(volumeSlider.to, newValue)
                                )

                                const sink = Pipewire.defaultAudioSink

                                if (sink && sink.audio)
                                    sink.audio.volume = volumeSlider.value

                                event.accepted = true
                            }
                        }

                        // Nord styling
                        background: Rectangle {
                            x: volumeSlider.leftPadding
                            y: volumeSlider.topPadding
                                + volumeSlider.availableHeight / 2
                                - height / 2

                            width: volumeSlider.availableWidth
                            height: 4
                            radius: 0
                            color: root.surfaceHover

                            Rectangle {
                                width: volumeSlider.visualPosition
                                    * parent.width
                                height: parent.height
                                radius: 0
                                color: root.accentColor
                            }
                        }

                        handle: Rectangle {
                            x: volumeSlider.leftPadding
                                + volumeSlider.visualPosition
                                * (volumeSlider.availableWidth - width)
                            y: volumeSlider.topPadding
                                + volumeSlider.availableHeight / 2
                                - height / 2

                            width: 14
                            height: 14
                            radius: 7
                            color: root.textColor
                            border.width: 2
                            border.color: root.accentColor
                        }
                    }

                    Text {
                        width: 50
                        height: parent.height

                        text: Math.round(volumeSlider.value * 100) + "%"
                        color: root.accentColor

                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter

                        font.pixelSize: 18
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }

                // Output device list
                Repeater {
                    id: deviceRepeater

                    // Destroy rows while closed and recreate on opening.
                    model: popup.visible ? root.audioDevices : []

                    delegate: Rectangle {
                        id: deviceRow

                        required property var modelData

                        readonly property bool isSelected:
                            Pipewire.defaultAudioSink === modelData

                        property bool isHovered: false

                        // Device icon selection
                        readonly property string deviceIcon: {
                            const name = (
                                (modelData.description || "") + " " +
                                (modelData.name || "")
                            ).toLowerCase()

                            // Headphones and headsets
                            if (name.includes("headphone") ||
                                name.includes("headset") ||
                                name.includes("earbud") ||
                                name.includes("earphone")) {
                                return "󰋋"
                            }

                            // USB devices, including USB headsets
                            if (name.includes("usb")) {
                                return "󰋋"
                            }

                            // Bluetooth audio devices
                            if (name.includes("bluetooth") ||
                                name.includes("bluez")) {
                                return "󰂯"
                            }

                            // HDMI and DisplayPort audio
                            if (name.includes("hdmi") ||
                                name.includes("displayport") ||
                                name.includes("display port")) {
                                return "󰡁"
                            }

                            // Speakers and built-in audio
                            if (name.includes("speaker") ||
                                name.includes("analog") ||
                                name.includes("built-in") ||
                                name.includes("built in")) {
                                return "󰓃"
                            }

                            return "󰓃"
                        }

                        width: contentColumn.width
                        height: root.rowHeight

                        // Always calculate colors from the current sink.
                        color: Pipewire.defaultAudioSink === modelData
                            ? root.accentColor
                            : (isHovered
                                ? root.surfaceHover
                                : root.surface)

                        border.width:
                            Pipewire.defaultAudioSink === modelData ? 1 : 0

                        border.color: root.borderColor

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 8
                            spacing: 10

                            // Device icon
                            Text {
                                width: 22
                                height: parent.height

                                text: deviceRow.deviceIcon

                                color: Pipewire.defaultAudioSink ===
                                    deviceRow.modelData
                                    ? root.bg
                                    : root.accentColor

                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter

                                font.pixelSize: 18
                                font.family: "JetBrainsMono Nerd Font"
                            }

                            // Device name
                            Text {
                                width: parent.width - 32
                                height: parent.height

                                text: deviceRow.modelData.description
                                    || deviceRow.modelData.name
                                    || "Unknown device"

                                color: Pipewire.defaultAudioSink ===
                                    deviceRow.modelData
                                    ? root.bg
                                    : root.textColor

                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight

                                font.pixelSize: 14
                                font.family: "JetBrainsMono Nerd Font"
                                font.bold: Pipewire.defaultAudioSink ===
                                    deviceRow.modelData
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onEntered: {
                                deviceRow.isHovered = true
                            }

                            onExited: {
                                deviceRow.isHovered = false
                            }

                            onClicked: {
                                deviceRow.isHovered = false
                                Pipewire.preferredDefaultAudioSink = modelData
                                popup.visible = false
                            }
                        }
                    }
                }
            }
        }
    }
}

