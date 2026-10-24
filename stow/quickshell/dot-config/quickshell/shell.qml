import Quickshell
import Quickshell.Services.Notifications
import QtQuick

import "modules" as Modules

ShellRoot {
    id: root

  NotificationServer {
    id: notificationServer

    actionsSupported: true
    bodySupported: true
    bodyMarkupSupported: true
    bodyHyperlinksSupported: true
    bodyImagesSupported: true
    imageSupported: true
    keepOnReload: true

    onNotification: notification => {
        console.info(
            "RECEIVED:",
            notification.appName,
            notification.summary
        )
                notification.tracked = true
    }
  }

    Modules.Notifications {
        server: notificationServer

        // Change this to match your Waybar height.
        waybarOffset: 14

        popupWidth: 370
        edgeMargin: 14
    }

    Modules.AudioOutput {
        id: audioPopup
    }
}
