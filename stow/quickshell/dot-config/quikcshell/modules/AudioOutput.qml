import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import Quickshell.Io
import ".." as Config

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

    // Track the current output sink.
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

    // Layout
    readonly property int popupMargin: 16
    readonly property int rowHeight: 40
    readonly property int volumeHeight: 42
    readonly property int itemSpacing: 8
    readonly property int headerHeight: 22
    readonly property int statusHeight: 14

    // Available audio output devices (sorted A-Z)
    property var audioDevices: Pipewire.nodes.values
        .filter(node =>
            node.isSink &&
            !node.isStream &&
            node.audio !== null
        )
        .sort((a, b) => {
            const nameA = (
                a.description ||
                a.name ||
                "Unknown device"
            )

            const nameB = (
                b.description ||
                b.name ||
                "Unknown device"
            )

            return nameA.localeCompare(
                nameB,
                undefined,
                {
                    sensitivity: "base",
                    numeric: true
                }
            )
        })

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

            color: Config.Theme.active.background
            radius: Config.Theme.active.radius
            border.width: Config.Theme.active.borderWidth
            border.color: Config.Theme.active.border
            clip: true

            Column {
                id: contentColumn

                anchors.fill: parent
                anchors.margins: root.popupMargin
                spacing: root.itemSpacing

                // Title
                Text {
                    text: "Audio Output"
                    color: Config.Theme.active.text

                    font.pixelSize: Config.Theme.active.titleFontSize
                    font.bold: true
                    font.family: Config.Theme.active.fontFamily
                }

                // PipeWire status
                Text {
                    text: "PipeWire ready: " + Pipewire.ready
                    color: Config.Theme.active.subtext

                    font.pixelSize: Config.Theme.active.fontSize
                    font.family: Config.Theme.active.fontFamily
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
                        color: Config.Theme.active.text
                        verticalAlignment: Text.AlignVCenter

                        font.pixelSize: 20
                        font.bold: true
                        font.family: Config.Theme.active.fontFamily
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

                        // Themed slider background
                        background: Rectangle {
                            x: volumeSlider.leftPadding
                            y: volumeSlider.topPadding
                                + volumeSlider.availableHeight / 2
                                - height / 2

                            width: volumeSlider.availableWidth
                            height: Config.Theme.active.sliderThickness
                            radius: Config.Theme.active.radius
                            color: Config.Theme.active.surfaceHover

                            Rectangle {
                                width: volumeSlider.visualPosition
                                    * parent.width
                                height: parent.height
                                radius: Config.Theme.active.radius
                                color: Config.Theme.active.accent
                            }
                        }

                        // Themed slider handle
                        handle: Rectangle {
                            x: volumeSlider.leftPadding
                                + volumeSlider.visualPosition
                                * (volumeSlider.availableWidth - width)
                            y: volumeSlider.topPadding
                                + volumeSlider.availableHeight / 2
                                - height / 2

                            width: Config.Theme.active.sliderHandleSize
                            height: Config.Theme.active.sliderHandleSize
                            radius: Config.Theme.active.sliderHandleRadius
                            color: Config.Theme.active.text
                            border.width: Config.Theme.active.borderWidth
                            border.color: Config.Theme.active.accent
                        }
                    }

                    Text {
                        width: 50
                        height: parent.height

                        text: Math.round(volumeSlider.value * 100) + "%"
                        color: Config.Theme.active.accent

                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter

                        font.pixelSize: 18
                        font.bold: true
                        font.family: Config.Theme.active.fontFamily
                    }
                }

                // Output device list
                Repeater {
                    id: deviceRepeater

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

                            if (name.includes("headphone") ||
                                name.includes("headset") ||
                                name.includes("earbud") ||
                                name.includes("earphone")) {
                                return "󰋋"
                            }

                            if (name.includes("usb")) {
                                return "󰋋"
                            }

                            if (name.includes("bluetooth") ||
                                name.includes("bluez")) {
                                return "󰂯"
                            }

                            if (name.includes("hdmi") ||
                                name.includes("displayport") ||
                                name.includes("display port")) {
                                return "󰡁"
                            }

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

                        color: isSelected
                            ? Config.Theme.active.accent
                            : (isHovered
                                ? Config.Theme.active.surfaceHover
                                : Config.Theme.active.surface)

                        border.width: isSelected
                            ? Config.Theme.active.borderWidth
                            : 0

                        border.color: Config.Theme.active.border

                        radius: Config.Theme.active.radius

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

                                color: deviceRow.isSelected
                                    ? Config.Theme.active.background
                                    : Config.Theme.active.accent

                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter

                                font.pixelSize: 18
                                font.family: Config.Theme.active.fontFamily
                            }

                            // Device name
                            Text {
                                width: parent.width - 32
                                height: parent.height

                                text: deviceRow.modelData.description
                                    || deviceRow.modelData.name
                                    || "Unknown device"

                                color: deviceRow.isSelected
                                    ? Config.Theme.active.background
                                    : Config.Theme.active.text

                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight

                                font.pixelSize: Config.Theme.active.fontSize
                                font.family: Config.Theme.active.fontFamily
                                font.bold: deviceRow.isSelected
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

