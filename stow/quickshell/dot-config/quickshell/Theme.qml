pragma Singleton

import QtQuick
import "themes" as Themes

QtObject {
    // CHANGE THIS TO SWITCH THEMES
    property string currentTheme: "Nord"

    // Available themes
    property QtObject catppuccin: Themes.Catppuccin {}
    property QtObject tokyoNight: Themes.TokyoNight {}
    property QtObject nord: Themes.Nord {}

    // Active theme
    readonly property QtObject active: {
        switch (currentTheme) {
            case "TokyoNight": return tokyoNight
            case "Nord": return nord
            case "Catppuccin": return catppuccin
            default: return catppuccin
        }
    }
}
