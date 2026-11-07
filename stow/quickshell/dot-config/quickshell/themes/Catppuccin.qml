import QtQuick
import Quickshell

QtObject {
    // Base — backgrounds (Catppuccin Mocha)
    readonly property color background:    "#1e1e2e"
    readonly property color surface:       "#313244"
    readonly property color surfaceHover:  "#45475a"
    readonly property color border:        "#585b70"

    // Text — typography
    readonly property color text:          "#cdd6f4"
    readonly property color textMuted:     "#bac2de"
    readonly property color textSubtle:    "#a6adc8"
    readonly property color subtext:       "#bac2de"

    // Accents
    readonly property color accent:        "#cba6f7"
    readonly property color accentAlt:     "#89b4fa"
    readonly property color accentDeep:    "#b4befe"
    readonly property color teal:          "#94e2d5"

    // Status colors
    readonly property color red:           "#f38ba8"
    readonly property color yellow:        "#f9e2af"
    readonly property color green:         "#a6e3a1"
    readonly property color orange:        "#fab387"
    readonly property color purple:        "#cba6f7"

    // Borders settings
    readonly property int radius: 0
    readonly property int borderWidth: 2

    // Typography
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 14
    readonly property int titleFontSize: 18

    // Sliders
    readonly property int sliderThickness: 4
    readonly property int sliderHandleSize: 14
    readonly property int sliderHandleRadius: 7
}
