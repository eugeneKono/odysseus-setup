import QtQuick
import Quickshell

QtObject {
    // Polar Night — backgrounds
    readonly property color background:  "#2e3440"
    readonly property color surface:     "#3b4252"
    readonly property color surfaceHover:  "#434c5e"
    readonly property color border:      "#88c0d0"

    // Snow Storm — text
    readonly property color text:        "#eceff4"
    readonly property color textMuted:   "#d8dee9"
    readonly property color textSubtle:  "#e5e9f0"
    readonly property color subtext: "#D8DEE9"

    // Frost — accents
    readonly property color accent:      "#88c0d0"
    readonly property color accentAlt:   "#81a1c1"
    readonly property color accentDeep:  "#5e81ac"
    readonly property color teal:        "#8fbcbb"

    // Aurora — status colors
    readonly property color red:       "#bf616a"
    readonly property color yellow:     "#ebcb8b"
    readonly property color green:     "#a3be8c"
    readonly property color orange:      "#d08770"
    readonly property color purple:      "#b48ead"

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
