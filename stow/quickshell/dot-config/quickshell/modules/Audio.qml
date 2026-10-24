import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Scope {
    id: root

    PwObjectTracker {
        objects: Pipewire.nodes
    }

    PanelWindow {
        id: panel

        anchors {
            top: true
            right: true
        }

        margins {
            top: 54
            right: 18
        }

        implicitWidth: 350
        implicitHeight: content.implicitHeight + 32
        color: "transparent"
        aboveWindows: true
        exclusionMode: ExclusionMode.Ignore
        focusable: true

        Rectangle {
            anchors.fill: parent
            radius: 18
            color: "#111c18"
            border.width: 1
            border.color: "#32473b"

            ColumnLayout {
                id: content

                anchors.fill: parent
                anchors.margins: 16
                spacing: 15

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Rectangle {
                        width: 38
                        height: 38
                        radius: 12
                        color: "#243b30"

                        Text {
                            anchors.centerIn: parent
                            text: "󰕾"
                            color: "#a7d7b5"
                            font.pixelSize: 23
                            font.family: "JetBrainsMono Nerd Font"
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "Sound"
                            color: "#e0e8d5"
                            font.pixelSize: 17
                            font.bold: true
                        }

                        Text {
                            text: "OUTPUT CONTROL"
                            color: "#789080"
                            font.pixelSize: 10
                            font.letterSpacing: 1.5
                        }
                    }

                    Text {
                        text: "●"
                        color: Pipewire.ready ? "#80c99a" : "#e5aa72"
                        font.pixelSize: 11
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#2b4035"
                }

                // Current output and volume
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        text: "󰓃"
                        color: "#80c99a"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 23
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3

                        Text {
                            text: Pipewire.defaultAudioSink
                                  ? (Pipewire.defaultAudioSink.description
                                     || Pipewire.defaultAudioSink.name)
                                  : "No output device"
                            color: "#e0e8d5"
                            font.pixelSize: 13
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "Default output"
                            color: "#789080"
                            font.pixelSize: 11
                        }
                    }

                    Text {
                        text: Pipewire.defaultAudioSink
                              && Pipewire.defaultAudioSink.audio
                              ? Math.round(
                                  Pipewire.defaultAudioSink.audio.volume * 100
                                ) + "%"
                              : "--"
                        color: "#a7d7b5"
                        font.pixelSize: 13
                        font.bold: true
                    }
                }

                // Volume slider
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        text: "󰕿"
                        color: "#a7b9a9"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 19
                    }

                    Slider {
                        id: volumeSlider

                        Layout.fillWidth: true
                        from: 0
                        to: 1
                        stepSize: 0.01

                        value: Pipewire.defaultAudioSink
                               && Pipewire.defaultAudioSink.audio
                               ? Pipewire.defaultAudioSink.audio.volume : 0

                        onMoved: {
                            if (Pipewire.defaultAudioSink
                                    && Pipewire.defaultAudioSink.audio) {
                                Pipewire.defaultAudioSink.audio.volume =
                                    value
                            }
                        }

                        background: Rectangle {
                            x: volumeSlider.leftPadding
                            y: volumeSlider.topPadding
                               + volumeSlider.availableHeight / 2
                               - height / 2
                            width: volumeSlider.availableWidth
                            height: 5
                            radius: 3
                            color: "#32473b"

                            Rectangle {
                                width: volumeSlider.visualPosition
                                       * parent.width
                                height: parent.height
                                radius: 3
                                color: "#80c99a"
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
                            color: "#c1e6c8"
                            border.color: "#80c99a"
                            border.width: 2
                        }
                    }

                    Text {
                        text: "󰕾"
                        color: "#a7b9a9"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 19
                    }
                }

                // Mute button
                Rectangle {
                    Layout.fillWidth: true
                    height: 42
                    radius: 11
                    color: muteMouse.containsMouse
                           ? "#32473b" : "#1b2b22"
                    border.width: 1
                    border.color: "#32473b"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        Text {
                            text: Pipewire.defaultAudioSink
                                  && Pipewire.defaultAudioSink.audio
                                  && Pipewire.defaultAudioSink.audio.muted
                                  ? "󰖁" : "󰕾"
                            color: "#a7d7b5"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 19
                        }

                        Text {
                            Layout.fillWidth: true
                            text: Pipewire.defaultAudioSink
                                  && Pipewire.defaultAudioSink.audio
                                  && Pipewire.defaultAudioSink.audio.muted
                                  ? "Unmute audio" : "Mute audio"
                            color: "#d4dfd0"
                            font.pixelSize: 12
                        }

                        Text {
                            text: "›"
                            color: "#789080"
                            font.pixelSize: 21
                        }
                    }

                    MouseArea {
                        id: muteMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            if (Pipewire.defaultAudioSink
                                    && Pipewire.defaultAudioSink.audio) {
                                Pipewire.defaultAudioSink.audio.muted =
                                    !Pipewire.defaultAudioSink.audio.muted
                            }
                        }
                    }
                }

                // Available outputs
                Text {
                    text: "OUTPUT DEVICES"
                    color: "#789080"
                    font.pixelSize: 10
                    font.letterSpacing: 1.5
                    Layout.topMargin: 2
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    Repeater {
                        model: Pipewire.nodes

                        delegate: Rectangle {
                            required property var modelData

                            readonly property bool validSink:
                                modelData.isSink
                                && !modelData.isStream
                                && modelData.audio !== null
                                && modelData.audio !== undefined

                            readonly property bool selected:
                                Pipewire.defaultAudioSink
                                && Pipewire.defaultAudioSink.id
                                   === modelData.id

                            Layout.fillWidth: true
                            implicitHeight: validSink ? 50 : 0
                            visible: validSink
                            radius: 11

                            color: selected
                                   ? "#243b30"
                                   : outputMouse.containsMouse
                                     ? "#1b2b22" : "transparent"

                            border.width: selected ? 1 : 0
                            border.color: "#507d60"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 10

                                Text {
                                    text: {
                                        const n = modelData.name.toLowerCase()
                                        if (n.includes("bluez")
                                                || n.includes("bluetooth"))
                                            return "󰋋"
                                        if (n.includes("hdmi")
                                                || n.includes("displayport"))
                                            return "󰍹"
                                        if (n.includes("headphone"))
                                            return "󰋋"
                                        return "󰓃"
                                    }

                                    color: selected
                                           ? "#a7d7b5" : "#9aafa0"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 20
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 3

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.description
                                              || modelData.name
                                        color: "#e0e8d5"
                                        font.pixelSize: 12
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: selected
                                              ? "CURRENT OUTPUT"
                                              : "Audio device"
                                        color: selected
                                               ? "#80c99a" : "#789080"
                                        font.pixelSize: 9
                                        font.letterSpacing: 0.7
                                    }
                                }

                                Text {
                                    visible: selected
                                    text: "✓"
                                    color: "#80c99a"
                                    font.pixelSize: 16
                                }
                            }

                            MouseArea {
                                id: outputMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    Pipewire.preferredDefaultAudioSink =
                                        modelData
                                }
                            }
                        }
                    }
                }

                // Footer
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 3

                    Text {
                        text: "PIPEWIRE  /  HYPRLAND"
                        color: "#53685b"
                        font.pixelSize: 9
                        font.letterSpacing: 1
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "󰌌"
                        color: "#789080"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 15
                    }
                }
            }
        }
    }
}
